class OBIN < ApplicationRecord
  self.table_name = 'OBIN'

  def self.search_storage(sl1code)
    begin 
      query = <<-SQL 
        select WhsCode, SL1Code
        from OBIN
        where SL1Code = '#{sl1code}'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        if result.count > 1
          puts "Csak egyetlen tétel lehetne az eredmény táblában! (odin.whscode)"
        end
        return result.first
      else
        return nil
      end
    end
  end   

end