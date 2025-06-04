class CalendarEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_calendar_event, only: [:show, :edit, :update, :destroy]

  def index
    @calendar_events = current_user.calendar_events.order(:start_time)
    @event_types = CalendarEvent.event_types.keys
  end

  def show
  end

  def new
    @calendar_event = current_user.calendar_events.build
    @calendar_event.start_time = DateTime.parse(params[:start]) if params[:start].present?
    @calendar_event.end_time = DateTime.parse(params[:end]) if params[:end].present?
    @calendar_event.all_day = params[:all_day] == 'true'
  end

  def create
    @calendar_event = current_user.calendar_events.build(calendar_event_params)
    
    if @calendar_event.save
      respond_to do |format|
        format.html { redirect_to dashboard_calendar_path, notice: 'Événement créé avec succès.' }
        format.json { render json: @calendar_event.to_fullcalendar_json }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @calendar_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @calendar_event.update(calendar_event_params)
      respond_to do |format|
        format.html { redirect_to dashboard_calendar_path, notice: 'Événement mis à jour avec succès.' }
        format.json { render json: @calendar_event.to_fullcalendar_json }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @calendar_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @calendar_event.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_calendar_path, notice: 'Événement supprimé avec succès.' }
      format.json { head :ok }
    end
  end

  # API endpoint pour FullCalendar
  def events_data
    start_date = Date.parse(params[:start]) if params[:start].present?
    end_date = Date.parse(params[:end]) if params[:end].present?
    
    events = current_user.calendar_events
    events = events.where('start_time >= ?', start_date) if start_date
    events = events.where('start_time <= ?', end_date) if end_date
    
    render json: events.map(&:to_fullcalendar_json)
  end

  private

  def set_calendar_event
    @calendar_event = current_user.calendar_events.find(params[:id])
  end

  def calendar_event_params
    params.require(:calendar_event).permit(:title, :description, :event_type, :start_time, :end_time, :all_day, :color, :related_model, :related_id)
  end
end
