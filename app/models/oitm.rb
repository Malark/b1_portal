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

end