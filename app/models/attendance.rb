class Attendance < ApplicationRecord
  belongs_to :event
  belongs_to :schedule
  belongs_to :member

  validates :event_id, presence: true
  validates :schedule_id, presence: true
  validates :member_id, presence: true

  enum answer: { unanswered: 0, ok: 1, maybe: 2, ng: 3 }

  def self.create_related_attendance(schedule)
    event = Event.find(schedule.event.id)
    members = event.members.distinct
    members.map { |member| self.create(event_id: event.id, schedule_id: schedule.id, member_id: member.id) }
  end
end
