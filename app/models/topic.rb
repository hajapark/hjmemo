class Topic < ApplicationRecord
  belongs_to :user

  has_many :notes, dependent: :destroy

  normalizes :name, with: ->(name) { name.strip }

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :user_id }
end
