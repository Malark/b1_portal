class KOM_GYARTBEERK < ApplicationRecord
  self.table_name = '@KOM_GYARTBEERK'
  before_create :generate_random_id


  def self.search_internal_label(charge_nr, itemcode)
    query = <<-SQL 
      select *
      from dbo.[@KOM_GYARTBEERK]
      where U_SARZSSZAM = '#{charge_nr}'
      and U_ItemCode = '#{itemcode}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      return result
    else
      return nil
    end
  end
  
  def self.search_master_label(master_label_id)
    query = <<-SQL 
      select *
      from dbo.[@KOM_GYARTBEERK]
      where U_VDASORSZAM = '#{master_label_id}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      return result
    else
      return nil
    end
  end  
  
  def self.update_internal_label(charge_nr, itemcode, master_label_id)
    current_date = Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s
    query = <<-SQL 
      update dbo.[@KOM_GYARTBEERK]
      set U_VDADATUM = '#{current_date}', U_VDAUSER = 'User', U_VDASORSZAM = '#{master_label_id}'
      where U_SARZSSZAM = '#{charge_nr}'
      and U_ItemCode = '#{itemcode}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query) 
      #if result.count > 0
      #  puts 'Felírás OK: #{row}'
      #else
      #  hiba = true  
      #end     
    #return hiba
  end


  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end

end