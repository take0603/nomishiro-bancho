class Member < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :schedules, through: :attendances

  accepts_nested_attributes_for :attendances

  validates :member_name, presence: true
end
