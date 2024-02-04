module AttendancesHelper
  def display_attendance_answer(member, schedule)
    Attendance.find_by(member_id: member.id, schedule_id: schedule.id).answer
  end
end
