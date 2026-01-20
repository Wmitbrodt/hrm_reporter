require "csv"

namespace :hrm do
  desc "Import HRM CSV files from a folder (expects users.csv, hrm_sessions.csv, hrm_data_points.csv)"
  task import: :environment do
    folder = ENV.fetch("FOLDER", nil)
    abort "Usage: bin/rails hrm:import FOLDER=path/to/unzipped/data" if folder.blank?

    users_path = File.join(folder, "users.csv")
    sessions_path = File.join(folder, "hrm_sessions.csv")
    points_path = File.join(folder, "hrm_data_points.csv")

    abort "Missing users.csv" unless File.exist?(users_path)
    abort "Missing hrm_sessions.csv" unless File.exist?(sessions_path)
    abort "Missing hrm_data_points.csv" unless File.exist?(points_path)

    puts "Importing users..."
    import_users(users_path)

    puts "Importing sessions..."
    import_sessions(sessions_path)

    puts "Computing session summaries + chart points..."
    compute_summaries(points_path)

    puts "Done."
  end
end

def import_users(path)
  rows = []
  CSV.foreach(path, headers: true) do |r|
    # Columns in prompt are positional; headers might vary. Use positions safely:
    # 0 User ID, 1 Created At, 2 Username, 3 Gender, 4 Age, 5..12 zones
    rows << {
      external_id: r[0].to_i,
      imported_created_at: Time.parse(r[1]),
      username: r[2],
      gender: r[3],
      age: r[4].to_i,
      zone1_min: r[5].to_i, zone1_max: r[6].to_i,
      zone2_min: r[7].to_i, zone2_max: r[8].to_i,
      zone3_min: r[9].to_i, zone3_max: r[10].to_i,
      zone4_min: r[11].to_i, zone4_max: r[12].to_i
    }

    if rows.size >= 500
      User.insert_all(rows, unique_by: :index_users_on_external_id)
      rows.clear
    end
  end
  User.insert_all(rows, unique_by: :index_users_on_external_id) if rows.any?
end

def import_sessions(path)
  rows = []
  CSV.foreach(path, headers: true) do |r|
    user = User.find_by(external_id: r[1].to_i)
    next unless user

    rows << {
      external_id: r[0].to_i,
      user_id: user.id,
      imported_created_at: Time.parse(r[2]),
      duration_secs: r[3].to_i,
      min_bpm: nil,
      max_bpm: nil,
      avg_bpm: nil,
      total_duration_secs: 0,
      weighted_bpm_sum: 0,
      zone1_secs: 0,
      zone2_secs: 0,
      zone3_secs: 0,
      zone4_secs: 0,
      chart_points: []
    }

    if rows.size >= 500
      HrmSession.insert_all(rows, unique_by: :index_hrm_sessions_on_external_id)
      rows.clear
    end
  end
  HrmSession.insert_all(rows, unique_by: :index_hrm_sessions_on_external_id) if rows.any?
end

def compute_summaries(points_path)
  # Strategy:
  # - Stream CSV in order
  # - Accumulate per session in memory
  # - Persist one session at a time
  #
  # Chart strategy:
  # - bucket readings into 10-second windows
  # - store ["ISO8601", bpm_avg_for_bucket]

  bucket_size = 10 # seconds

  current_session_ext_id = nil
  session = nil
  user = nil

  min_bpm = nil
  max_bpm = nil
  total_secs = 0
  weighted_sum = 0

  z1 = z2 = z3 = z4 = 0

  bucket_start = nil
  bucket_weighted = 0
  bucket_secs = 0
  chart_points = []

  flush_bucket = lambda do
    return if bucket_secs <= 0 || bucket_start.nil?
    avg = (bucket_weighted.to_f / bucket_secs.to_f).round(1)
    chart_points << [bucket_start.utc.iso8601, avg]
  end

  flush_session = lambda do
    return if session.nil?

    flush_bucket.call

    avg_bpm = total_secs > 0 ? (weighted_sum.to_f / total_secs.to_f).round(2) : nil

    session.update!(
      min_bpm: min_bpm,
      max_bpm: max_bpm,
      total_duration_secs: total_secs,
      weighted_bpm_sum: weighted_sum,
      avg_bpm: avg_bpm,
      zone1_secs: z1,
      zone2_secs: z2,
      zone3_secs: z3,
      zone4_secs: z4,
      chart_points: chart_points
    )
  end

  CSV.foreach(points_path, headers: true) do |r|
    sess_ext_id = r[0].to_i
    bpm = r[1].to_i
    start_time = Time.parse(r[2])
    duration = r[4].to_i

    if current_session_ext_id != sess_ext_id
      # flush previous
      flush_session.call

      # reset + load new
      current_session_ext_id = sess_ext_id
      session = HrmSession.find_by(external_id: sess_ext_id)
      if session.nil?
        # No session record -> skip until next
        next
      end
      user = session.user

      min_bpm = nil
      max_bpm = nil
      total_secs = 0
      weighted_sum = 0
      z1 = z2 = z3 = z4 = 0

      bucket_start = nil
      bucket_weighted = 0
      bucket_secs = 0
      chart_points = []
    end

    next if session.nil? || duration <= 0

    min_bpm = bpm if min_bpm.nil? || bpm < min_bpm
    max_bpm = bpm if max_bpm.nil? || bpm > max_bpm

    total_secs += duration
    weighted_sum += bpm * duration

    case user.zone_for_bpm(bpm)
    when 1 then z1 += duration
    when 2 then z2 += duration
    when 3 then z3 += duration
    when 4 then z4 += duration
    end

    # Chart bucketing
    if bucket_start.nil?
      bucket_start = start_time
    end

    # If we've moved beyond the bucket window, flush and reset
    if (start_time - bucket_start) >= bucket_size
      flush_bucket.call
      bucket_start = start_time
      bucket_weighted = 0
      bucket_secs = 0
    end

    bucket_weighted += bpm * duration
    bucket_secs += duration

    # Hard cap the number of chart points so charts stay fast
    if chart_points.size > 800
      # if we exceed, keep every 2nd point (simple downsample)
      chart_points = chart_points.each_with_index.select { |_, i| i.even? }.map(&:first)
    end
  end

  flush_session.call
end
