class KOM_ATTAROLAS < ApplicationRecord
  self.table_name = '@KOM_ATTAROLAS'
  before_create :generate_random_id

  validates :U_SARZSSZAM, presence: true


  def self.search_batch_location(charge_nr, itemcode)
    begin 
      query = <<-SQL 
        select OBTN.ItemCode, OBTN.DistNumber, OBIN.WhsCode, OBIN.Sl1Code
        from OBTN
        inner join OBBQ on OBBQ.SnBMDAbs = OBTN.AbsEntry
        inner join OBIN on OBBQ.BinAbs = OBIN.AbsEntry and OBBQ.WhsCode = OBIN.WhsCode
        where OBTN.ItemCode = '#{itemcode}'
        and OBTN.DistNumber = '#{charge_nr}'
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

  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end  

end