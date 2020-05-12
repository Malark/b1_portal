class User_old < ApplicationRecord
  has_many :messages, dependent: :destroy
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..15 }
  has_secure_password
  scope :online, -> { where(online: true) }
end