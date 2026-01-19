class User < ApplicationRecord
  has_many :hrm_sessions

  def zone_for_bpm(bpm)
    return 1 if bpm.between?(zone1_min, zone1_max)
    return 2 if bpm.between?(zone2_min, zone2_max)
    return 3 if bpm.between?(zone3_min, zone3_max)
    return 4 if bpm.between?(zone4_min, zone4_max)
    nil
  end
end
