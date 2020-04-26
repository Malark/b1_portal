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

  def self.update_checked_labels(labels)
    #hiba = false
    labels.each do |row|
      query = <<-SQL 
        update dbo.[@MOS_OWSD]
        set U_mezo09 = getdate(), U_mezo10 = 'User'
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

end
