class DashboardController < ApplicationController
  def index
    @recent_sessions =
      HrmSession
        .order(created_at: :desc)
        .limit(10)
        .to_a

    @global_min = HrmSession.global_min_bpm
    @global_max = HrmSession.global_max_bpm
    @global_avg = HrmSession.global_avg_bpm
    @zone_percentages = HrmSession.global_zone_percentages
  end
end
