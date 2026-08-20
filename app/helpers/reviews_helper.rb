module ReviewsHelper
  def review_delay_label(delay)
    if delay < 1.day
      "#{delay.in_minutes.to_i}분"
    else
      "#{delay.in_days.to_i}일"
    end
  end
end
