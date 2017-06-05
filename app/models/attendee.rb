class Attendee < Person
  include FamilyMember

  CONFERENCE_STATUS_CHECKED_IN = 'Checked-In'.freeze

  CONFERENCE_STATUSES = [
    'Registered',
    'Expected',
    'Exempt',
    CONFERENCE_STATUS_CHECKED_IN,
    'Cru17 Not Required'
  ].freeze

  after_initialize :set_default_seminary
  before_save :touch_conference_status_changed, if: :conference_status_changed?

  belongs_to :family
  belongs_to :seminary

  has_many :conference_attendances, dependent: :destroy
  has_many :conferences, through: :conference_attendances
  has_many :course_attendances, dependent: :destroy
  has_many :courses, through: :course_attendances

  accepts_nested_attributes_for :course_attendances, allow_destroy: true
  accepts_nested_attributes_for :meal_exemptions, allow_destroy: true

  validates :family_id, presence: true
  validates_associated :course_attendances, :meal_exemptions

  def conference_names
    conferences.pluck(:name).join(', ')
  end

  def check_in!
    update!(conference_status: CONFERENCE_STATUS_CHECKED_IN)
  end

  protected

  def set_default_seminary
    self.seminary_id ||= Seminary.default&.id
  end

  def touch_conference_status_changed
    self.conference_status_changed_at = Time.zone.now
  end
end
