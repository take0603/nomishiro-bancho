module AttendancesHelper
  def display_attendance_answer(member, schedule)
    ans = Attendance.find_by(member_id: member.id, schedule_id: schedule.id).answer
    case ans
    when "ok"
      content_tag(:i, nil, class: "fa-regular fa-circle")
    when "maybe"
      content_tag(:i, nil, class: "fa-solid fa-play fa-rotate-270")
    when "ng"
      content_tag(:i, nil, class: "fa-solid fa-xmark")
    else
      return
    end
  end

  def display_count_answer(schedule, idx)
    schedule.attendances.where(answer: idx).count
  end
end
