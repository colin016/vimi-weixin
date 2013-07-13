# encoding:utf-8

class AddUserRefToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :user_id, :integer
  end
end
