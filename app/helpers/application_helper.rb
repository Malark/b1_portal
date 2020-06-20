module ApplicationHelper

  require 'barby/barcode/ean_13'
  require 'barby/barcode/ean_8'
  require 'barby/barcode/qr_code'
  require 'barby/outputter/png_outputter'  

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
