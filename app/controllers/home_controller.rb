class HomeController < ApplicationController
  before_action :authenticate_user!, except: :top

  def top
  end

  def mypage
    events = current_user.events
    @events_attendance = events.where(date: nil)
    @events_before_date = events.where("date >= ?", Time.now)
    @events_payment = events.where("date < ?", Time.now).where.missing(:payments) |
                      events.joins(:payment_details).where("date < ?", Time.now).where(payment_details: {is_paid: false}).distinct
  end
end
