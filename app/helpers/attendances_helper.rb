module AttendancesHelper
  def display_attendance_answer(member, schedule)
    ans = Attendance.find_by(member_id: member.id, schedule_id: schedule.id).answer
    case ans
    when "ok"
      tag.i class: "fa-regular fa-circle"
    when "maybe"
      tag.i class: "fa-solid fa-play fa-rotate-270"
    when "ng"
      tag.i class: "fa-solid fa-xmark"
    end
  end

  def display_count_answer(schedule, idx)
    schedule.attendances.where(answer: idx).count
  end
end
