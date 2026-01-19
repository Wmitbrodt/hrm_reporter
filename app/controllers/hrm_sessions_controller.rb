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
end
