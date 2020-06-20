class OITW < ApplicationRecord
  self.table_name = 'OITW'

  def self.onhand(whscode, itemcode)
    query = <<-SQL 
      select OnHand
      from OITW
      where WhsCode = '#{whscode}'
      and ItemCode = '#{itemcode}'
    SQL

    results = ActiveRecord::Base.connection.exec_query(query)
    if results.count > 0
      if results.count > 1
        puts "Csak egyetlen tétel lehetne az eredmény táblában! (oitw.onhand)"
      end
      return results.first
    else
      return nil
    end
  end


end  