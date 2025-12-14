# == Schema Information
#
# Table name: users
#
#  id                   :uuid, not null
#  created_at           :timestamptz, not null
#  email                :citext, not null
#  password_digest      :text, not null
#  role                 :enum, not null, default: patient
#  status               :enum, not null, default: active
#  updated_at           :timestamptz, not null
#

class User < ApplicationRecord
  # Validaciones
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  validates :role, presence: true, inclusion: { in: %w[patient provider admin] }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }

  # Encriptación de contraseña
  has_secure_password

  # Relaciones
  has_one :patient, dependent: :destroy
  has_one :provider, dependent: :destroy

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :patients, -> { where(role: 'patient') }
  scope :providers, -> { where(role: 'provider') }
  scope :admins, -> { where(role: 'admin') }

  # Métodos
  def patient?
    role == 'patient'
  end

  def provider?
    role == 'provider'
  end

  def admin?
    role == 'admin'
  end

  def active?
    status == 'active'
  end
end

