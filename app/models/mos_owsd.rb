class MOS_OWSD < ApplicationRecord
  self.table_name = '@MOS_OWSD'

  #scope :search_master_label, -> (master_label) { where("U_raklap2 = #{master_label}") }

  def self.search_master_labels(delivery_note)
    query = <<-SQL 
      select distinct U_raklap2
      from dbo.[@MOS_OWSD]
      where U_forrasbiz = #{delivery_note} 
      and U_mezo09 is null
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      #result.each do |row|
      #  puts row["DocNum"]
      #end  
      return result
    else
      return nil
    end
  end


  def self.search_master_label_by_label_id(master_label_id)
    query = <<-SQL 
      select distinct U_raklap2, U_ItemCode
      from dbo.[@MOS_OWSD]
      where U_raklap2 = '#{master_label_id}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      return result
    else
      return nil
    end
  end

  
  def self.update_checked_labels(labels, current_user)
    #hiba = false
    #formatting date
    current_date = Time.now.strftime("%Y-%m-%d").to_s
    labels.each do |row|
      query = <<-SQL 
        update dbo.[@MOS_OWSD]
        set U_mezo09 = '#{current_date}', U_mezo10 = '#{current_user}'
        --set U_mezo09 = getdate(), U_mezo10 = 'User'
        where U_raklap2 = #{row}
      SQL
      result = ActiveRecord::Base.connection.exec_query(query) 
      #if result.count > 0
      #  puts 'Felírás OK: #{row}'
      #else
      #  hiba = true  
      #end     
    end  
    #return hiba
  end


  #-------- RFID conversation -----------

  def self.search_labels(delivery_note)
    query = <<-SQL 
      select *
      from dbo.[@MOS_OWSD]
      where U_forrasbiz = #{delivery_note} 
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      return result
    else
      return nil
    end
  end


  def self.update_rfid_label(code, lcid_palette, lcid_klt, rfid_palette, rfid_klt)
    query = <<-SQL 
      update dbo.[@MOS_OWSD]
      set U_lcid_raklap = '#{lcid_palette}', U_lcid_doboz = '#{lcid_klt}', U_rfid_raklap = '#{rfid_palette}', U_rfid_doboz = '#{rfid_klt}'
      where Code = #{code}
    SQL
    result = ActiveRecord::Base.connection.exec_query(query) 
  end  

end