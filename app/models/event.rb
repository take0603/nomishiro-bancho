class Event < ApplicationRecord
  belongs_to :user
  has_many :schedules, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :members, through: :attendances, dependent: :destroy
  has_many :payments, dependent: :destroy

  accepts_nested_attributes_for :schedules, allow_destroy: true

  validates :user_id, presence: true
  validates :event_name, presence: true

  include Hashid::Rails
end
