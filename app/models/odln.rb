class ODLN < ApplicationRecord
  self.table_name = 'ODLN'

  def self.search_from_lookup(vevocsoport)
    begin 
      #sql = "SELECT * FROM ODLN WHERE DocEntry >= 15112"
      #records_array = ActiveRecord::Base.connection.exec_query(sql)
      #records_array.each do |row|
      #  puts row["DocNum"]
      #end  
      #return records_array.last["DocNum"]

      query_old = <<-SQL 
        select ODLN.DocNum, ODLN.CardCode, ODLN.CardName, ODLN.DocDueDate, ODLN.ShipToCode
        from ODLN
        inner join OCRD on ODLN.CardCode = OCRD.CardCode
        inner join [@MOS_OWSD] on ODLN.DocNum = [@MOS_OWSD].U_forrasbiz
        where OCRD.U_VEVOCSOPORT = #{vevocsoport} 
        and [@MOS_OWSD].U_mezo09 is null
        --and (ODLN.U_SZALLEVKESZ is null or ODLN.U_SZALLEVKESZ = 'N')
        and ODLN.DocDueDate >= '2020.03.15'
        group by ODLN.DocNum, ODLN.CardCode, ODLN.CardName, ODLN.DocDueDate, ODLN.ShipToCode
        order by ODLN.DocNum
      SQL

      query = <<-SQL 
        select ODLN.DocNum, ODLN.CardCode, ODLN.CardName, ODLN.DocDueDate, ODLN.ShipToCode, sum(1) as palettes
        from ODLN
        inner join OCRD on ODLN.CardCode = OCRD.CardCode
        inner join dbo.EDI_Rakomanykepzes_raklapok on ODLN.DocNum = dbo.EDI_Rakomanykepzes_raklapok.U_forrasbiz
        where OCRD.U_VEVOCSOPORT = #{vevocsoport}
        and dbo.EDI_Rakomanykepzes_raklapok.U_mezo09 is null
        --and (ODLN.U_SZALLEVKESZ is null or ODLN.U_SZALLEVKESZ = 'N')
        and ODLN.DocDueDate >= '2020.03.15'
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
