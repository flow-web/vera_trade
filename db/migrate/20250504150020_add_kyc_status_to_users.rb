class AddKycStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :kyc_status, :string
  end
end
