# == Schema Information
#
# Table name: orders
#
#  id                   :uuid, not null
#  created_at           :timestamptz, not null
#  hearing_aid_id       :uuid, not null
#  notes                :text
#  patient_id           :uuid, not null
#  provider_id          :uuid, not null
#  status               :enum, not null, default: pending
#  total_price          :decimal, not null
#  updated_at           :timestamptz, not null
#

class Order < ApplicationRecord
  # Relaciones
  belongs_to :patient
  belongs_to :provider
  belongs_to :hearing_aid

  # Validaciones
  validates :status, presence: true, inclusion: { in: %w[pending confirmed processing shipped delivered cancelled] }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :set_total_price, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :processing, -> { where(status: 'processing') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :recent, -> { order(created_at: :desc) }

  # Métodos
  def pending?
    status == 'pending'
  end

  def confirmed?
    status == 'confirmed'
  end

  def processing?
    status == 'processing'
  end

  def shipped?
    status == 'shipped'
  end

  def delivered?
    status == 'delivered'
  end

  def cancelled?
    status == 'cancelled'
  end

  def formatted_total_price
    "$#{total_price.round(2)}"
  end

  private

  def set_total_price
    self.total_price ||= hearing_aid&.price || 0
  end
end

