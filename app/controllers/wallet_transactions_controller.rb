class WalletTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [ :show ]

  def index
    @transactions = current_user.wallet_transactions
      .includes(:wallet)
      .order(created_at: :desc)
      .limit(50)
  end

  def show
  end

  private

  def set_transaction
    @transaction = current_user.wallet_transactions.find(params[:id])
  end
end
