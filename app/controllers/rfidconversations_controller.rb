class RfidconversationsController < ApplicationController


  def rfid_conversation_index
    @actu_step = 1
  end


  def get_delivery_note
    if params[:delivery_note_nr].blank?
      @actu_step = 1
      flash.now[:danger] = "Kérem adjon meg egy szállítólevelet!"
    else
      @delivery_note_nr = params[:delivery_note_nr]
      @all_labels = MOS_OWSD.search_labels(params[:delivery_note_nr])
      if @all_labels == nil
        @actu_step = 1
        flash.now[:danger] = "Nem található adat!"
      else
        @actu_step = 2   
        dict_6bit = set_dict_6bit

        #test_lcid = '1JUN499774731123456789'
        #test_lcid = '1JUN364740217000165570'
        #test_rfid = create_rfid(test_lcid, dict_6bit)

        puts ''
        puts '-------------------------------------------------------'

        @all_labels.each do |label|

          puts ''
          lcid_palette = create_lcid('Master', label["U_raklap2"])
          rfid_palette = create_rfid(lcid_palette, dict_6bit)

          puts ''
          
          lcid_klt = create_lcid('KLT', label["U_doboz2"])
          rfid_klt = create_rfid(lcid_klt, dict_6bit)

          puts ''
          puts '-------------------------------------------------------'

          MOS_OWSD.update_rfid_label(label["Code"], lcid_palette, lcid_klt, rfid_palette, rfid_klt)
        end 
        
        #refresh query with the updated fields
        @all_labels = MOS_OWSD.search_labels(params[:delivery_note_nr])

      end   
    end 
    
    respond_to do |format|
      format.js { render partial: 'rfid_conversation' }
    end     
  end


  private
  
  def create_lcid(label_type, label_id)
    #'6J' + 'UN' + '364740217' + REPLICATE('0', CONVERT(VARCHAR, 9 - LEN(t0.U_raklap2))) + t0.U_raklap2 AS RFID
    #'1J' + 'UN' + '364740217' + REPLICATE('0', CONVERT(VARCHAR, 9 - LEN(t0.U_doboz2))) + t0.U_doboz2 AS RFID
    lcid = ''
    prefix = ''
    
    if label_type == 'Master'
      prefix = '6JUN'
      puts 'raklap címke: ' + label_id    
    else
      prefix = '1JUN'
      puts 'doboz címke: ' + label_id
    end
    duns = '364740217'
    id = label_id.rjust(9, '0')
    lcid = prefix + duns + id

    puts 'LC ID: ' + lcid

    return lcid
  end  


  def create_rfid(lcid, dict_6bit)
    # step-0: add the permanent two prefix to the hexa RFID string (49, A2)
    rfid = '49A2'
    rfid_log = '49 A2 '

    # step-1: convert every character of the string to 6 bit binary code and finally add Eot and Space character at the end
    string_6bit = ''
    string_6bit_log = ''
    lcid.each_char do |char|
      converted = dict_6bit[char]
      if converted 
        string_6bit += dict_6bit[char]
        string_6bit_log += dict_6bit[char] + ' '
      else
        string_6bit += '******'
        string_6bit_log += '******' + ' '
      end
    end
    string_6bit += dict_6bit['EoT'] + dict_6bit['Space']
    string_6bit_log += dict_6bit['EoT'] + ' ' + dict_6bit['Space']
    puts '6 bites, tagolva: ' + string_6bit_log
    puts '6 bites,  egyben: ' + string_6bit
    
    
    # step-2: split the binary giant string into 8 char binary codes
    arr = string_6bit.scan(/.{8}/)
    string_8bit = ''
    arr.each do |item|
      string_8bit += item + ' '
      rfid += item.to_i(2).to_s(16).rjust(2, '0').upcase
      rfid_log += item.to_i(2).to_s(16).rjust(2, '0').upcase + ' '
    end
    puts '8 bites, tagolva: ' + string_8bit
    puts 'RFID, tagolva: ' + rfid_log
    puts 'RFID,  egyben: ' + rfid

    return rfid
  end


  def set_dict_6bit
    dict = 
      {
        "EoT" => "100001", 
        "Space" => "100000",
        "(" => "101000", 
        ")" => "101001", 
        "*" => "101010",
        "+" => "101011",
        "," => "101100",
        "-" => "101101",
        "." => "101110",
        "/" => "101111",
        "0" => "110000",
        "1" => "110001",
        "2" => "110010",
        "3" => "110011",
        "4" => "110100",
        "5" => "110101",
        "6" => "110110",
        "7" => "110111",
        "8" => "111000",
        "9" => "111001",
        ":" => "111010",
        ";" => "111011",
        "<" => "111100",
        "=" => "111101",
        ">" => "111110",
        "?" => "111111",
        "@" => "000000",
        "A" => "000001",
        "B" => "000010",
        "C" => "000011",
        "D" => "000100",
        "E" => "000101",
        "F" => "000110",
        "G" => "000111",
        "H" => "001000",
        "I" => "001001",
        "J" => "001010",
        "K" => "001011",
        "L" => "001100",
        "M" => "001101",
        "N" => "001110",
        "O" => "001111",
        "P" => "010000",
        "Q" => "010001",
        "R" => "010010",
        "S" => "010011",
        "T" => "010100",
        "U" => "010101",
        "V" => "010110",
        "W" => "010111",
        "X" => "011000",
        "Y" => "011001",
        "Z" => "011010",
        "[" => "011011",
        "]" => "011101"
      }
    return dict
  end

end