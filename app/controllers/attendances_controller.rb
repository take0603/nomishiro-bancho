class AttendancesController < ApplicationController
  def new
    @event = Event.find_by_hashid!(params[:event_id])
    @member = Member.new
    schedules = @event.schedules.order(:schedule_date)
    schedules.map { |schedule| @member.attendances.build(schedule_id: schedule.id) }
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      flash[:notice] = "出欠を回答しました。"
      redirect_to event_attendances_path
    else
      @event = Event.find_by_hashid!(params[:event_id])
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find_by_hashid!(params[:event_id])
    @members = @event.members.distinct.order(:id)
    @schedules = @event.schedules.order(:schedule_date)
  end

  def edit
    @event = Event.find_by_hashid!(params[:event_id])
    @member = Member.find(params[:member_id])
    @attendance = Attendance.joins(:schedule).where(member_id: @member.id).order(:schedule_date)
  end

  def update
    @member = Member.find(params[:member_id])
    if @member.update(member_params)
      flash[:notice] = "出欠を回答しました。"
      redirect_to event_attendances_path
    else
      @event = Event.find_by_hashid!(params[:event_id])
      @attendance = Attendance.joins(:schedule).where(member_id: @member.id).order(:schedule_date)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = Member.find(params[:member_id])
    @member.destroy
    flash[:notice] = "回答が削除されました。"
    redirect_to event_attendances_path
  end

  private

  def member_params
    params.require(:member).permit(:id, :member_name,
                                   attendances_attributes: [:id, :event_id, :schedule_id, :answer])
  end
end
