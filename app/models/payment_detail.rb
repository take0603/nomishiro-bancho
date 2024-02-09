class PaymentDetail < ApplicationRecord
  belongs_to :payment

  validates :participant, presence: true
  validates :fee, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
