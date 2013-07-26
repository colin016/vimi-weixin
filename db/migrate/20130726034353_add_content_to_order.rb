class AddContentToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :content, :string
  end
end
