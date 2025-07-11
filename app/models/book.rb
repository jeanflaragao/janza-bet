class Book < ApplicationRecord
  belongs_to :user

  has_many :transactions, dependent: :destroy
  has_many :daily_balances, dependent: :destroy

  validates :owner, presence: true
  validates :name, presence: true

  scope :active, -> { where(inactive: false) }
  scope :inactive, -> { where(inactive: true) }
  
  before_validation :set_description

  def last_daily_balance
    daily_balances.order(date: :desc).limit(1).pluck(:balance).first
  end
  
  private

  def set_description
    self.description = "#{name} - #{owner}" if description.blank?
  end
end
# 