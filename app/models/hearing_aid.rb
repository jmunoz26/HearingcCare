# == Schema Information
#
# Table name: hearing_aids
#
#  id                   :uuid, not null
#  created_at           :timestamptz, not null
#  manufacturer         :text, not null
#  model                :text, not null
#  price                :decimal, not null
#  updated_at           :timestamptz, not null
#

class HearingAid < ApplicationRecord
  # Relaciones
  has_many :orders, dependent: :restrict_with_error

  # Validaciones
  validates :manufacturer, presence: true
  validates :model, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_manufacturer, ->(manufacturer) { where(manufacturer: manufacturer) }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :recent, -> { order(created_at: :desc) }

  # Métodos
  def full_name
    "#{manufacturer} #{model}"
  end

  def formatted_price
    "$#{price.round(2)}"
  end
end

