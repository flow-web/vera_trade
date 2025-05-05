module DashboardHelper
  def transaction_type_color(type)
    case type.to_sym
    when :deposit
      "bg-green-100 text-green-600"
    when :payment
      "bg-red-100 text-red-600"
    when :withdraw
      "bg-orange-100 text-orange-600"
    when :conversion
      "bg-blue-100 text-blue-600"
    when :refund
      "bg-indigo-100 text-indigo-600"
    when :fee
      "bg-gray-100 text-gray-600"
    else
      "bg-gray-100 text-gray-600"
    end
  end
  
  def transaction_type_icon(type)
    case type.to_sym
    when :deposit
      "bi-arrow-down-circle"
    when :payment
      "bi-cash"
    when :withdraw
      "bi-arrow-up-circle"
    when :conversion
      "bi-arrow-left-right"
    when :refund
      "bi-arrow-counterclockwise"
    when :fee
      "bi-dash-circle"
    else
      "bi-circle"
    end
  end
  
  def transaction_status_color(status)
    case status.to_sym
    when :pending
      "bg-yellow-100 text-yellow-800"
    when :confirmed
      "bg-green-100 text-green-800"
    when :failed
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end 