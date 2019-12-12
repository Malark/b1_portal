class Kom_gyartbeerk < ApplicationRecord
  self.table_name = '@KOM_GYARTBEERK'
  before_create :generate_random_id

  private 
  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end

end