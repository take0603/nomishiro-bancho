class Payment < ApplicationRecord
  belongs_to :event
  has_many :payment_details, dependent: :destroy

  accepts_nested_attributes_for :payment_details, allow_destroy: true

  validates :event_id, presence: true
  validates :payment_name, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
