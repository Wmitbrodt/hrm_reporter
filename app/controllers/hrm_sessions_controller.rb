class HrmSessionsController < ApplicationController
  def index
    @sessions = HrmSession
      .includes(:user)
      .order(imported_created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show
    @session = HrmSession.find(params[:id])
  end

  def chart
    session = HrmSession.find(params[:id])
    points = downsample_points(session.chart_points || [], 200)

    render json: {
      points: points.map { |t, bpm| { x: t, y: bpm.to_f } }
    }
  end

  private

  def downsample_points(points, max_points)
    return points if points.size <= max_points

    step = (points.size.to_f / max_points).ceil
    points.each_slice(step).map do |slice|
      first_t = slice.first&.first
      avg = slice.sum { |(_t, bpm)| bpm.to_f } / slice.size
      [first_t, avg.round(1)]
    end
  end
end
