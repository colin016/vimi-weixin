class AddClientInfoToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :receiver_name, :string
    add_column :orders, :receiver_address, :string
    add_column :orders, :receiver_code, :string
    add_column :orders, :receiver_contact, :string
  end
end
