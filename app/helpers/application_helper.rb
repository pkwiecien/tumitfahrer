module ApplicationHelper

  def full_title(page_title)
    whole_title = "TUMitfahrer"
    if page_title.empty?
      whole_title
    else
      "#{whole_title} | #{page_title}"
    end
  end
end
