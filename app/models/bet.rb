class Bet < ApplicationRecord
  belongs_to :book
  belongs_to :tipster, optional: true
  belongs_to :user
  STATUSES = ["won", "lost", "void", "half won", "half lost"]

  before_save :calculate_result

  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  
  private

  def calculate_result
    case status
    when "won"
      self.result = stake * odd
    when "lost"
      self.result = 0
    when "void"
      self.result = stake
    when "half won"
      self.result = stake + (stake * (odd - 1) / 2)
    when "half lost"
      self.result = stake / 2
    else
      self.result ||= 0
    end
  end
end
