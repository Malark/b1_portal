class KOM_HABIGENY_TETEL < ApplicationRecord
  self.table_name = '@KOM_HABIGENY_TETEL'
  before_create :generate_random_id

  validates :U_IGENY_SARZSSZAM, presence: true


  def self.find_components(request_charge_nr)
    query = <<-SQL 
      select *
      from dbo.[@KOM_HABIGENY_TETEL]
      where U_IGENY_SARZSSZAM = '#{request_charge_nr}'
    SQL
    results = ActiveRecord::Base.connection.exec_query(query)
    if results.count > 0
      return results
    else
      return nil
    end    
  end

  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end  

end
