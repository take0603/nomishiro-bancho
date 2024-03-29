class Schedule < ApplicationRecord
  belongs_to :event
  has_many :attendances, dependent: :destroy
  has_many :members, through: :attendances

  validates :schedule_date, presence: true

  default_scope { order(schedule_date: :asc) }
end
