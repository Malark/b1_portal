class OBBQ < ApplicationRecord
  self.table_name = 'OBBQ'


  def self.search_batches(request_nr, itemcode, whscode)
    begin 
      query = <<-SQL 
        select OBBQ.AbsEntry, 'OBBQ' as Source, OBBQ.ItemCode, OBTN.ItemName, OBTN.DistNumber, OBBQ.OnHandQty, OBBQ.WhsCode, OBIN.SL1Code, OBTN.InDate, OBTN.ExpDate, dbo.[@KOM_HABIGENY_MOZGAS].U_MarkedQty
        from OBBQ
        inner join OBIN on OBBQ.BinAbs = OBIN.AbsEntry and OBBQ.WhsCode = OBIN.WhsCode
        inner join OBTN on OBBQ.SnBMDAbs = OBTN.AbsEntry
        left outer join dbo.[@KOM_HABIGENY_MOZGAS] on dbo.[@KOM_HABIGENY_MOZGAS].U_IGENY_SARZSSZAM = '#{request_nr}' and dbo.[@KOM_HABIGENY_MOZGAS].U_source = 'OBBQ' and OBBQ.AbsEntry = dbo.[@KOM_HABIGENY_MOZGAS].U_AbsEntry
        where OBBQ.ItemCode = '#{itemcode}'
        and OBBQ.WhsCode = '#{whscode}'
        and OBBQ.OnHandQty > 0
      SQL
      results = ActiveRecord::Base.connection.exec_query(query)
      if results.count > 0
        return results
      else
        return nil
      end
    end
  end   


  def self.find_batch_by_absentry(request_nr, absentry)
    begin 
      query = <<-SQL 
        select OBBQ.AbsEntry, 'OBBQ' as Source, OBBQ.ItemCode, OBTN.ItemName, OBTN.DistNumber, OBBQ.OnHandQty, OBBQ.WhsCode, OBIN.SL1Code, OBTN.InDate, OBTN.ExpDate, dbo.[@KOM_HABIGENY_MOZGAS].U_MarkedQty 
        from OBBQ
        inner join OBIN on OBBQ.BinAbs = OBIN.AbsEntry and OBBQ.WhsCode = OBIN.WhsCode
        inner join OBTN on OBBQ.SnBMDAbs = OBTN.AbsEntry
        left outer join dbo.[@KOM_HABIGENY_MOZGAS] on dbo.[@KOM_HABIGENY_MOZGAS].U_IGENY_SARZSSZAM = '#{request_nr}' and dbo.[@KOM_HABIGENY_MOZGAS].U_source = 'OBBQ' and OBBQ.AbsEntry = dbo.[@KOM_HABIGENY_MOZGAS].U_AbsEntry
        where OBBQ.AbsEntry = '#{absentry}'
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

# Batches of a material SQL query
#SELECT T0.ItemCode, t2.itemname, t2.DistNumber, t0.OnHandQty, t0.whscode, t1.SL1Code, t2.InDate, t2.ExpDate
#from obbq t0
#inner join obin t1 on t0.binabs = t1.AbsEntry and t0.WhsCode = t1.WhsCode
#inner join obtn t2 on t0.SnBMDAbs = t2.AbsEntry
#Where t0.ItemCode = '14565'
#and t0.WhsCode = '1_alap3'