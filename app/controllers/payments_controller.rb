class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user

  def index
    @event = Event.find(params[:event_id])
  end

  def new
    @event = Event.find(params[:event_id])
    @payment = @event.payments.build
    members = @event.members.distinct
    members.map { |member| @payment.payment_details.build(participant: member.member_name) }
  end

  def create
    @event = Event.find(params[:event_id])
    @payment = @event.payments.build(payment_params)
    if @payment.save
      flash[:notice] = "支払表を作成しました。"
      redirect_to event_payment_path(id: @payment.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find(params[:event_id])
    @payment = Payment.find(params[:id])
    @participant = @payment.payment_details.order([fee: :desc, id: :asc])
  end

  def edit
    @event = Event.find(params[:event_id])
    @payment = Payment.find(params[:id])
  end

  def update
    @event = Event.find(params[:event_id])
    @payment = Payment.find(params[:id])
    if @payment.update(payment_params)
      flash[:notice] = "支払表を編集しました。"
      redirect_to event_payment_path(id: @payment.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    flash[:notice] = "支払表が削除されました。"
    redirect_to event_payments_path
  end

  private

  def payment_params
    params.require(:payment).permit(:id, :event_id, :payment_name, :amount,
                                    payment_details_attributes: [:id, :payment_id, :participant, :fee, :is_paid, :_destroy])
  end

  def correct_user
    redirect_to events_path unless current_user == Event.find(params[:event_id]).user
  end
end
