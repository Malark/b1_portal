class Kom_User < ApplicationRecord
  self.table_name = '@KOM_USERS'
  alias_attribute :password_digest, :U_PASSWORD_DIGEST
  alias_attribute :username, :U_USERNAME
  alias_attribute :email, :U_EMAIL
  alias_attribute :admin, :U_ADMIN
  alias_attribute :roles, :U_ROLES
  alias_attribute :approver, :U_PROD_APPROVER
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
  validates :roles, presence: true, 
            length: { is: 2 }            
  has_secure_password


  def self.get_warehouse_role(user)
    if user != nil
      roles = user.U_ROLES
      if roles == nil 
        roles = 'NN'
      end
      if roles[0].upcase == 'I'
        return true
      else
        return false
      end
    else
      retrun false
    end
  end


  def self.get_production_role(user)
    if user != nil
      roles = user.U_ROLES
      if roles == nil 
        roles = 'NN'
      end
      if roles[1].upcase == 'I'
        return true
      else
        return false
      end
    else
      return false
    end
  end


  def self.get_production_approval_role(user)
    if user != nil
      approval_role = user.U_PROD_APPROVER
      if approval_role == nil 
        return false
      else
        if approval_role == '1'
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end  


  private 

  def generate_random_id
    self.Code = SecureRandom.uuid
    self.Name = self.Code
  end

end