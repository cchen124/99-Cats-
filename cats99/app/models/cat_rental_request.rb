# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :integer          not null, primary key
#  cat_id     :integer          not null
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           default("PENDING"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CatRentalRequest < ActiveRecord::Base
  validates :cat_id, :start_date, :end_date, :status, presence: true
  validates :status, inclusion: ["PENDING", "APPROVED", "DENIED"]
  validate :overlapping_requests

  belongs_to :cat

  def other_rentals
    cat.cat_rental_requests.where.not("cat_rental_requests.id = ?", self.id || -1)
      .where("cat_rental_requests.status = ?", "APPROVED")
  end

  def overlapping_requests
    overlap = other_rentals.any? do |rental|
      self.start_date.between?(rental.start_date, rental.end_date) ||
      self.end_date.between?(rental.start_date, rental.end_date)
    end
    
    errors[:base] << "Overlapping requests not allowed" if overlap
  end
end
