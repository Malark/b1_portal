class OIBQ < ApplicationRecord
  self.table_name = 'OIBQ'


  def self.search_units(request_nr, itemcode, whscode)
    begin 
      query = <<-SQL 
        select OIBQ.AbsEntry, 'OIBQ' as Source, OIBQ.ItemCode, OITM.ItemName, '' as DistNumber, OIBQ.OnHandQty, OIBQ.WhsCode, OBIN.SL1Code, '' as InDate, '' as ExpDate, dbo.[@KOM_HABIGENY_MOZGAS].U_MarkedQty
        from OIBQ
        inner join OBIN on OIBQ.BinAbs = OBIN.AbsEntry and OIBQ.WhsCode = OBIN.WhsCode
        inner join OITM on OIBQ.ItemCode = OITM.ItemCode
        left outer join dbo.[@KOM_HABIGENY_MOZGAS] on dbo.[@KOM_HABIGENY_MOZGAS].U_IGENY_SARZSSZAM = '#{request_nr}' and dbo.[@KOM_HABIGENY_MOZGAS].U_source = 'OIBQ' and OIBQ.AbsEntry = dbo.[@KOM_HABIGENY_MOZGAS].U_AbsEntry
        where OIBQ.ItemCode = '#{itemcode}'
        and OIBQ.WhsCode = '#{whscode}'
        and OIBQ.OnHandQty > 0
      SQL
      results = ActiveRecord::Base.connection.exec_query(query)
      if results.count > 0
        return results
      else
        return nil
      end
    end
  end   


  def self.find_unit_by_absentry(request_nr, absentry)
    begin 
      query = <<-SQL 
        select OIBQ.AbsEntry, 'OIBQ' as Source, OIBQ.ItemCode, OITM.ItemName, '' as DistNumber, OIBQ.OnHandQty, OIBQ.WhsCode, OBIN.SL1Code, '' as InDate, '' as ExpDate, dbo.[@KOM_HABIGENY_MOZGAS].U_MarkedQty
        from OIBQ
        inner join OBIN on OIBQ.BinAbs = OBIN.AbsEntry and OIBQ.WhsCode = OBIN.WhsCode
        inner join OITM on OIBQ.ItemCode = OITM.ItemCode
        left outer join dbo.[@KOM_HABIGENY_MOZGAS] on dbo.[@KOM_HABIGENY_MOZGAS].U_IGENY_SARZSSZAM = '#{request_nr}' and dbo.[@KOM_HABIGENY_MOZGAS].U_source = 'OIBQ' and OIBQ.AbsEntry = dbo.[@KOM_HABIGENY_MOZGAS].U_AbsEntry
        where OIBQ.AbsEntry = '#{absentry}'
      SQL
      results = ActiveRecord::Base.connection.exec_query(query)
      if results.count > 0
        return results
      else
        return nil
      end
    end
  end     
  
end

