# frozen_string_literal: true

# User model specifications
class User < ApplicationRecord
  # formats the email to down case before saving
  attr_accessor :remember_token
  before_create :create_activation_digest
  before_save { self.email = email.downcase }

  # Allows email validations for correct format
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze

  validates :username, presence: true, length: { minimum: 3, maximum: 50 }
  validates :password, presence: true, length: { minimum: 6, maximum: 255 }
  validates :email, presence: true, length: { minimum: 10, maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  has_many :posts

  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      Digest::SHA1.hexdigest string.to_s
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?

    Digest::SHA1.hexdigest(remember_digest).is_password?(remember_token)
  end
end
