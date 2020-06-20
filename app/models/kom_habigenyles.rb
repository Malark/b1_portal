class KOM_HABIGENYLES < ApplicationRecord
  self.table_name = '@KOM_HABIGENYLES'
  before_create :generate_random_id

  validates :U_SARZSSZAM, presence: true, 
  uniqueness: { case_sensitive: false }

  scope :all_open, -> { where("U_STATUS != 'C'") }

  def self.generate_charge_nr
    query = <<-SQL 
      select TOP 1 *
      from dbo.[@KOM_HABIGENYLES]
      order by U_SARZSSZAM DESC
    SQL

    result = ActiveRecord::Base.connection.exec_query(query)
    if result.count > 0
      if result.count > 1
        puts "Csak egyetlen tétel lehetne az eredmény táblában! (oitm.search_item)"
      end
      return result.first
    else
      return nil
    end
  end  


  def self.update_approved_request(id, current_user)
    current_date = Time.now.strftime("%Y-%m-%d").to_s
    query = <<-SQL 
      update dbo.[@KOM_HABIGENYLES]
      set U_STATUS = 'A', U_JOVAHAGY_DATUM = '#{current_date}', U_JOVAHAGYO = '#{current_user}'
      where Code = '#{id}'
    SQL
    result = ActiveRecord::Base.connection.exec_query(query) 
  end  


  def self.find_requests_in_progress(request_id)
    query = <<-SQL 
      select *
      from dbo.[@KOM_HABIGENYLES]
      where U_SARZSSZAM != '#{request_id}' and  U_STATUS = 'I'
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