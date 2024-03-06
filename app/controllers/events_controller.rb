class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: [:show, :edit, :update, :destroy]

  def index
    @events = current_user.events
  end

  def new
    @event = current_user.events.build
    @event.schedules.build
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:notice] = "イベントが作成されました。"
      redirect_to event_path(@event)
    else
      render "new", status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      # schedule追加時、出欠表で既存メンバー分の当該日を未回答とするため回答のレコードを作成する
      if @event.members.present? && @event.schedules.where.missing(:members)
        @event.schedules.where.missing(:members).map { |schedule| Attendance.create_related_attendance(schedule) }
      end
      flash[:notice] = "イベント情報が更新されました。"
      redirect_to event_path(@event)
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "イベントが削除されました。"
    redirect_to events_path
  end

  private

  def event_params
    params.require(:event).permit(:id, :user_id, :event_name, :explanation, :date, :deadline,
                                  schedules_attributes: [:id, :event_id, :schedule_date, :_destroy])
  end

  def correct_user
    redirect_to events_path unless current_user == Event.find(params[:id]).user
  end
end
