class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: [:show, :edit, :update, :destroy]

  def index
    @events = current_user.events
  end

  def new
    @event = current_user.events.build
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
      flash[:notice] = "イベント情報が更新されました。"
      redirect_to event_path(@event.id)
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
    params.require(:event).permit(:user_id, :event_name, :explanation)
  end

  def correct_user
    redirect_to events_path unless current_user == Event.find(params[:id]).user
  end
end
