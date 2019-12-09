class OWOR < ApplicationRecord
  self.table_name = 'OWOR'

  def self.search_from_lookup(itemcode)
    begin 

      query = <<-SQL 
        select DocNum
        from OWOR
        where Status = 'R' and Type = 'S' and ItemCode = '#{itemcode}'
        and CmpltQty < PlannedQty
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