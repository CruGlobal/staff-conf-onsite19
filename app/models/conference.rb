class Conference < ApplicationRecord
  has_paper_trail

  include Monetizable

  monetize_attr :price_cents, numericality: {
    greater_than_or_equal_to: -1_000_000,
    less_than_or_equal_to:     1_000_000
  }

  has_many :conference_attendances
  has_many :attendees, through: :conference_attendances

  def audit_name
    "#{super}: #{name}"
  end
end