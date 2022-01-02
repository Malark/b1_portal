class KOM_HABIGENY_MOZGAS < ApplicationRecord
  self.table_name = '@KOM_HABIGENY_MOZGAS'
  before_create :generate_random_id
  validates :U_AbsEntry, presence: true



  def self.find_components(request_charge_nr)
    query = <<-SQL 
      select *
      from dbo.[@KOM_HABIGENY_MOZGAS]
      where U_IGENY_SARZSSZAM = '#{request_charge_nr}'
    SQL
    results = ActiveRecord::Base.connection.exec_query(query)
    if results.count > 0
      return results
    else
      return nil
    end    
  end  


  def self.find_transaction_by_absentry(source, absentry, batch_nr)
    begin 
      query = <<-SQL 
        select *
        from dbo.[@KOM_HABIGENY_MOZGAS]
        where U_IGENY_SARZSSZAM = '#{batch_nr}' and U_Source = '#{source}' and U_AbsEntry = '#{absentry}'
      SQL
      results = ActiveRecord::Base.connection.exec_query(query)
      if results.count > 0
        return results
      else
        return nil
      end
    end
  end   


  def self.delete_transaction(id)
    query = <<-SQL 
      delete from dbo.[@KOM_HABIGENY_MOZGAS]
      where Code = '#{id}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query) 
  end    


  def self.find_transactions_by_batch(batch_nr)
    begin 
      query = <<-SQL 
        select *
        from dbo.[@KOM_HABIGENY_MOZGAS]
        where U_IGENY_SARZSSZAM = '#{batch_nr}'
        order by U_MATERIAL_TYPE DESC, U_ItemCode ASC, U_MarkedQty DESC
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