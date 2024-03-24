class User < ApplicationRecord
  has_many :events
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image

  validates :name, presence: true
  validate :image_content_type
  validate :image_size

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲスト"
    end
  end

  def image_content_type
    if image.attached? && !image.content_type.in?(%w(image/jpeg image/png image/gif))
      errors.add(:image, ':ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください。')
    end
  end

  def image_size
    if image.attached? && image.blob.byte_size > 1.megabytes
      errors.add(:image, ':1MB以下のファイルをアップロードしてください。')
    end
  end
end
