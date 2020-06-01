class KOM_HABIGENYLES < ApplicationRecord
  self.table_name = '@KOM_HABIGENYLES'
  before_create :generate_random_id
  scope :all_open, -> { where("U_STATUS != 'C'") }
 

  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end  

end