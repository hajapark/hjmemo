class Note < ApplicationRecord
  belongs_to :topic

  validates :question, presence: true
  validates :answer, presence: true
end
