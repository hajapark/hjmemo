class Note < ApplicationRecord
  MAX_ANSWER_IMAGES = 5
  MAX_ANSWER_IMAGE_SIZE = 5.megabytes
  ALLOWED_ANSWER_IMAGE_TYPES = %w[
    image/jpeg
    image/png
    image/webp
  ].freeze

  belongs_to :topic

  has_many_attached :answer_images

  validates :question, presence: true
  validates :answer, presence: true
  validate :acceptable_answer_images

  private

  def acceptable_answer_images
    if answer_images.size > MAX_ANSWER_IMAGES
      errors.add(:answer_images, "는 최대 5개까지 첨부할 수 있습니다.")
    end

    answer_images.each do |image|
      unless ALLOWED_ANSWER_IMAGE_TYPES.include?(image.content_type)
        errors.add(:answer_images, "는 JPEG, PNG, WebP 파일만 사용할 수 있습니다.")
      end

      if image.byte_size > MAX_ANSWER_IMAGE_SIZE
        errors.add(:answer_images, "는 파일당 5MB 이하여야 합니다.")
      end
    end
  end
end
