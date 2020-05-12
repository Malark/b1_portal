module ApplicationHelper

  def mobile_device?
    if is_mobile_device? 
      puts "mobile deviceeeeeeeeeeeeeeeeeeeeeeeee"
    else
      puts "PC deviceeeeeeeeeeeeeeeeeeeee"
    end
    is_mobile_device?
  end


  def gravatar_for(user, options = { size: 80})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "img-circle")
  end

end
