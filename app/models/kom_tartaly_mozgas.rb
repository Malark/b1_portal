class KOM_TARTALY_MOZGAS < ApplicationRecord
  self.table_name = '@KOM_TARTALY_MOZGAS'
  before_create :generate_random_id
  # validates :U_IGENY_SARZSSZAM, presence: true


  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end  

end
