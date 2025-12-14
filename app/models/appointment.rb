# == Schema Information
#
# Table name: appointments
#
#  id                   :uuid, not null
#  created_at           :timestamptz, not null
#  end_at               :timestamptz
#  notes                :text
#  patient_id           :uuid, not null
#  provider_id          :uuid, not null
#  start_at             :timestamptz, not null
#  status               :enum, not null, default: scheduled
#  updated_at           :timestamptz, not null
#

class Appointment < ApplicationRecord
  # Relaciones
  belongs_to :patient
  belongs_to :provider

  # Validaciones
  validates :start_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[scheduled confirmed cancelled completed] }
  validate :end_at_after_start_at

  # Scopes
  scope :scheduled, -> { where(status: 'scheduled') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :completed, -> { where(status: 'completed') }
  scope :upcoming, -> { where('start_at > ?', Time.current).order(start_at: :asc) }
  scope :past, -> { where('start_at < ?', Time.current).order(start_at: :desc) }
  scope :today, -> { where(start_at: Time.current.beginning_of_day..Time.current.end_of_day) }

  # Métodos
  def duration
    return nil unless end_at && start_at
    ((end_at - start_at) / 60).round # en minutos
  end

  def scheduled?
    status == 'scheduled'
  end

  def confirmed?
    status == 'confirmed'
  end

  def cancelled?
    status == 'cancelled'
  end

  def completed?
    status == 'completed'
  end

  def upcoming?
    start_at > Time.current
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?

    if end_at <= start_at
      errors.add(:end_at, 'debe ser posterior a la hora de inicio')
    end
  end
end

