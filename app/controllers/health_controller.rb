class HealthController < ActionController::API
  def show
    checks = {
      status: "ok",
      timestamp: Time.current.iso8601,
      database: check_database,
      queue: check_queue,
      version: Rails.application.config.x.version || "unknown"
    }

    status_code = checks.values_at(:database, :queue).all? { |c| c[:status] == "ok" } ? :ok : :service_unavailable
    render json: checks, status: status_code
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok" }
  rescue => e
    { status: "error", message: e.message }
  end

  def check_queue
    # SolidQueue is used in this project
    if defined?(SolidQueue)
      { status: "ok", pending: SolidQueue::Job.where(finished_at: nil).count }
    else
      { status: "ok", note: "no queue configured" }
    end
  rescue => e
    { status: "error", message: e.message }
  end
end
