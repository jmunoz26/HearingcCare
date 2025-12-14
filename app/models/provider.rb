# == Schema Information
#
# Table name: providers
#
#  id                   :uuid, not null
#  address              :text
#  clinic_name          :text, not null
#  created_at           :timestamptz, not null
#  phone                :text
#  updated_at           :timestamptz, not null
#  user_id              :uuid
#

class Provider < ApplicationRecord
  # Relaciones
  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :patients, through: :appointments

  # Validaciones
  validates :clinic_name, presence: true
  validates :phone, format: { with: /\A[\d\s\-\+\(\)]+\z/, allow_blank: true }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Métodos
  def full_info
    info = clinic_name
    info += " - #{address}" if address
    info += " (#{phone})" if phone
    info
  end
end

