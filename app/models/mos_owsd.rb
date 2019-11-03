class MOS_OWSD < ApplicationRecord
  self.table_name = '@MOS_OWSD'

  def self.search_master_labels(delivery_note)
    #return "aaa"

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

end
