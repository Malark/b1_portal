class KOM_HABIGENYLES < ApplicationRecord
  self.table_name = '@KOM_HABIGENYLES'
  before_create :generate_random_id


  

  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end  

end