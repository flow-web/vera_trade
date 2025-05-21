module WalletTransactionsHelper
  def transaction_type_badge_class(transaction)
    case transaction.transaction_type
    when 'deposit'
      'badge-success'
    when 'withdrawal'
      'badge-error'
    when 'purchase'
      'badge-warning'
    when 'sale'
      'badge-info'
    when 'refund'
      'badge-secondary'
    else
      'badge-ghost'
    end
  end
end
