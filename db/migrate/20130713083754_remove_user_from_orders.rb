class RemoveUserFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :user
  end

  def down
    add_column :orders, :user, :integer
  end
end
