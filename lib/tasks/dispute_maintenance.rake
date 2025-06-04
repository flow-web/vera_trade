namespace :disputes do
  desc "Maintenance tasks for disputes and support system"
  
  task maintenance: :environment do
    puts "Starting dispute and support system maintenance..."
    
    # Auto-close resolved tickets after 7 days
    old_tickets = SupportTicket.where(
      status: 'resolved', 
      resolved_at: ..7.days.ago
    )
    
    old_tickets.find_each do |ticket|
      ticket.update!(status: 'closed')
      puts "Auto-closed ticket #{ticket.ticket_number}"
    end
    
    # Auto-close resolved disputes after 7 days
    old_disputes = Dispute.where(
      status: 'resolved',
      resolved_at: ..7.days.ago
    )
    
    old_disputes.find_each do |dispute|
      dispute.update!(status: 'closed')
      puts "Auto-closed dispute #{dispute.reference_number}"
    end
    
    # Expire old dispute resolutions
    expired_count = 0
    DisputeResolution.pending.where('expires_at < ?', Time.current).find_each do |resolution|
      resolution.mark_as_expired!
      expired_count += 1
    end
    
    puts "Expired #{expired_count} dispute resolutions"
    puts "Maintenance completed!"
  end
  
  task auto_close_tickets: :environment do
    desc "Auto-close old resolved tickets"
    
    count = 0
    SupportTicket.where(
      status: 'resolved', 
      resolved_at: ..7.days.ago
    ).find_each do |ticket|
      ticket.update!(status: 'closed')
      count += 1
    end
    
    puts "Auto-closed #{count} resolved support tickets"
  end
  
  task auto_close_disputes: :environment do
    desc "Auto-close old resolved disputes"
    
    count = 0
    Dispute.where(
      status: 'resolved',
      resolved_at: ..7.days.ago
    ).find_each do |dispute|
      dispute.update!(status: 'closed')
      count += 1
    end
    
    puts "Auto-closed #{count} resolved disputes"
  end
  
  task expire_resolutions: :environment do
    desc "Mark expired dispute resolutions as expired"
    
    expired_count = DisputeResolution.expire_old_resolutions!
    puts "Expired #{expired_count} dispute resolutions"
  end
  
  task cleanup_old_evidences: :environment do
    desc "Clean up rejected evidences older than 30 days"
    
    old_evidences = DisputeEvidence.where(
      status: 'rejected',
      created_at: ..30.days.ago
    )
    
    count = old_evidences.count
    old_evidences.destroy_all
    
    puts "Cleaned up #{count} old rejected evidences"
  end
  
  task generate_reports: :environment do
    desc "Generate dispute and support statistics"
    
    puts "\n=== DISPUTE STATISTICS ==="
    puts "Open disputes: #{Dispute.open.count}"
    puts "Resolved disputes: #{Dispute.where(status: 'resolved').count}"
    puts "Escalated disputes: #{Dispute.where(status: 'escalated').count}"
    puts "Average resolution time: #{calculate_average_resolution_time('Dispute')} days"
    
    puts "\n=== SUPPORT STATISTICS ==="
    puts "Open tickets: #{SupportTicket.open.count}"
    puts "Resolved tickets: #{SupportTicket.where(status: 'resolved').count}"
    puts "Urgent tickets: #{SupportTicket.where(priority: 'urgent').count}"
    puts "Average resolution time: #{calculate_average_resolution_time('SupportTicket')} days"
    
    puts "\n=== EVIDENCE STATISTICS ==="
    puts "Pending evidences: #{DisputeEvidence.pending.count}"
    puts "Approved evidences: #{DisputeEvidence.approved.count}"
    puts "Rejected evidences: #{DisputeEvidence.rejected.count}"
    
    puts "\n=== RESOLUTION STATISTICS ==="
    puts "Pending resolutions: #{DisputeResolution.pending.count}"
    puts "Accepted resolutions: #{DisputeResolution.accepted.count}"
    puts "Expired resolutions: #{DisputeResolution.expired.count}"
  end
  
  private
  
  def calculate_average_resolution_time(model_name)
    model = model_name.constantize
    resolved_items = model.where.not(resolved_at: nil)
    
    return 0 if resolved_items.empty?
    
    total_time = resolved_items.sum do |item|
      (item.resolved_at - item.created_at) / 1.day
    end
    
    (total_time / resolved_items.count).round(1)
  end
end

# Schedule these tasks to run daily
# Add to your cron job or use whenever gem:
# 0 2 * * * cd /path/to/app && bundle exec rake disputes:maintenance RAILS_ENV=production 