class User < ApplicationRecord
  has_many :topics, dependent: :destroy
  has_many :notes, through: :topics

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
end
