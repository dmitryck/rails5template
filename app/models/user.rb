class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :lockable, :recoverable, :registerable, :timeoutable, :trackable, :validatable
  # not used: :rememberable, :omniauthable
end
