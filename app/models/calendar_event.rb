class CalendarEvent < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :start_time, presence: true
  validates :event_type, presence: true
  
  # Types d'événements
  enum :event_type, {
    meeting: 'meeting',
    video_call: 'video_call',
    reminder: 'reminder',
    appointment: 'appointment',
    delivery: 'delivery',
    personal: 'personal',
    business: 'business'
  }, default: 'reminder'
  
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('start_time < ?', Time.current) }
  scope :today, -> { where(start_time: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(start_time: Date.current.beginning_of_week..Date.current.end_of_week) }
  
  before_save :set_end_time_if_missing
  before_save :set_default_color
  
  def duration
    return nil unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(1)
  end
  
  def related_object
    return nil unless related_model && related_id
    related_model.constantize.find_by(id: related_id)
  end
  
  def related_object=(object)
    self.related_model = object.class.name
    self.related_id = object.id
  end
  
  # Format pour FullCalendar
  def to_fullcalendar_json
    {
      id: id,
      title: title,
      start: start_time.iso8601,
      end: end_time&.iso8601,
      allDay: all_day,
      color: color || default_color_for_type,
      extendedProps: {
        description: description,
        eventType: event_type,
        relatedModel: related_model,
        relatedId: related_id
      }
    }
  end
  
  private
  
  def set_end_time_if_missing
    if all_day?
      self.end_time = start_time.end_of_day if end_time.blank?
    else
      self.end_time = start_time + 1.hour if end_time.blank?
    end
  end
  
  def set_default_color
    self.color = default_color_for_type if color.blank?
  end
  
  def default_color_for_type
    case event_type
    when 'video_call' then '#3B82F6'  # Bleu
    when 'meeting' then '#10B981'     # Vert
    when 'reminder' then '#F59E0B'    # Orange
    when 'appointment' then '#8B5CF6' # Violet
    when 'delivery' then '#EF4444'    # Rouge
    when 'personal' then '#6B7280'    # Gris
    when 'business' then '#059669'    # Vert foncé
    else '#6B7280'
    end
  end
end
