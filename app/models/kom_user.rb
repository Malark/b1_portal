class Kom_User < ApplicationRecord
  self.table_name = '@KOM_USERS'
  alias_attribute :password_digest, :U_PASSWORD_DIGEST
  alias_attribute :username, :U_USERNAME
  alias_attribute :email, :U_EMAIL
  alias_attribute :admin, :U_ADMIN
  alias_attribute :roles, :U_ROLES
  before_create :generate_random_id

  before_save { self.email = email.downcase }
  validates :username, presence: true, 
  uniqueness: { case_sensitive: false },
  length: { in: 3..30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
            length: { maximum: 100 },
            uniqueness: { case_sensitive: false },
            format: { with: VALID_EMAIL_REGEX }
  has_secure_password

  
  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end

end