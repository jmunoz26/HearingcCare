# == Schema Information
#
# Table name: patients
#
#  id                   :uuid, not null
#  created_at           :timestamptz, not null
#  dob                  :date
#  insurance_id         :text
#  name                 :text, not null
#  phone                :text
#  updated_at           :timestamptz, not null
#  user_id              :uuid
#

class Patient < ApplicationRecord
  # Relaciones
  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :providers, through: :appointments

  # Validaciones
  validates :name, presence: true
  validates :phone, format: { with: /\A[\d\s\-\+\(\)]+\z/, allow_blank: true }

  # Scopes
  scope :with_insurance, -> { where.not(insurance_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Métodos
  def age
    return nil unless dob
    ((Time.zone.now - dob.to_time) / 1.year.seconds).floor
  end

  def full_info
    info = name
    info += " (#{age} años)" if age
    info += " - #{phone}" if phone
    info
  end
end

