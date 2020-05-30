class OITM < ApplicationRecord
  self.table_name = 'OITM'

  def self.search_itemname(itemcode)
    begin 
      query = <<-SQL 
        select ItemName
        from OITM
        where ItemCode = '#{itemcode}'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        return result
      else
        return nil
      end
    end
  end  

  def self.search_item(itemcode)
    begin 
      query = <<-SQL 
        select *
        from OITM
        where ItemCode = '#{itemcode}'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        if result.count > 1
          puts "Csak egyetlen tétel lehetne az eredmény táblában! (oitm.search_item)"
        end
        return result.first
      else
        return nil
      end
    end
  end  


end