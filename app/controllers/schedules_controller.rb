class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: [:new, :create, :edit, :update]

  def new
    @schedule = Schedule.new
  end

  def create
    @event = Event.find(params[:event_id])
    @schedule = @event.schedules.build(schedule_params)
    if @schedule.save
      Attendance.create_related_attendance(@schedule) if @event.members.present? && @schedule.members.blank? 
      flash[:notice] = "候補日が追加されました。"
      redirect_to event_path(@event)
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:event_id])
    @schedule = @event.schedules.find(params[:id])
  end

  def update
    @event = Event.find(params[:event_id])
    @schedule = @event.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to event_path(@event)
    else
      render "edit", status: :unprocessable_entity
    end
  end

  private
  def schedule_params
    params.require(:schedule).permit(:event_id, :schedule_date, :is_confirmed)
  end

  def correct_user
    redirect_to events_path unless current_user == Event.find(params[:event_id]).user
  end
end
