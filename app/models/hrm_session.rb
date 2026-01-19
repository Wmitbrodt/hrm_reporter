class HrmSession < ApplicationRecord
  belongs_to :user

  scope :recent_first, -> { order(imported_created_at: :desc) }

  def chart_series
    # stored as array of ["2026-01-01T12:00:00Z", 123]
    (chart_points || []).map { |t, bpm| [Time.iso8601(t), bpm] }
  end

  def zone_seconds_hash
    {
      zone1: zone1_secs.to_i,
      zone2: zone2_secs.to_i,
      zone3: zone3_secs.to_i,
      zone4: zone4_secs.to_i
    }
  end

  # Global aggregates across sessions (fast because we precomputed)
  def self.global_min_bpm
    minimum(:min_bpm)
  end

  def self.global_max_bpm
    maximum(:max_bpm)
  end

  def self.global_avg_bpm
    total_weighted = sum(:weighted_bpm_sum)
    total_secs = sum(:total_duration_secs)
    return nil if total_secs.to_i <= 0
    (total_weighted.to_f / total_secs.to_f).round(2)
  end

  def self.global_zone_percentages
    total_secs = sum(:total_duration_secs).to_f
    return {} if total_secs <= 0

    z1 = sum(:zone1_secs).to_f
    z2 = sum(:zone2_secs).to_f
    z3 = sum(:zone3_secs).to_f
    z4 = sum(:zone4_secs).to_f

    {
      zone1: (z1 / total_secs * 100).round(1),
      zone2: (z2 / total_secs * 100).round(1),
      zone3: (z3 / total_secs * 100).round(1),
      zone4: (z4 / total_secs * 100).round(1)
    }
  end
end
