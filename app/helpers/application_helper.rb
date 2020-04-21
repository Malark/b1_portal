module ApplicationHelper

  def mobile_device?
    if is_mobile_device? 
      puts "mobile deviceeeeeeeeeeeeeeeeeeeeeeeee"
    else
      puts "PC deviceeeeeeeeeeeeeeeeeeeee"
    end
    is_mobile_device?
  end

end
