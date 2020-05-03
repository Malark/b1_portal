class ODLN < ApplicationRecord
  self.table_name = 'ODLN'

  def self.search_from_lookup(vevocsoport)
    begin 

      query = <<-SQL 
        select ODLN.DocNum, ODLN.CardCode, ODLN.CardName, ODLN.DocDueDate, ODLN.ShipToCode, sum(1) as palettes
        from ODLN
        inner join OCRD on ODLN.CardCode = OCRD.CardCode
        inner join dbo.EDI_Rakomanykepzes_raklapok on ODLN.DocNum = dbo.EDI_Rakomanykepzes_raklapok.U_forrasbiz
        where OCRD.U_VEVOCSOPORT = #{vevocsoport}
        and dbo.EDI_Rakomanykepzes_raklapok.U_mezo09 is null
        and (ODLN.U_SZALLEVKESZ is null or ODLN.U_SZALLEVKESZ = 'N')
        and ODLN.DocDueDate >= '2020.04.15'
        group by ODLN.DocNum, ODLN.CardCode, ODLN.CardName, ODLN.DocDueDate, ODLN.ShipToCode
        order by ODLN.DocNum
      SQL

      #        and (ODLN.U_SZALLEVKESZ is null or ODLN.U_SZALLEVKESZ = 'N')

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

end
