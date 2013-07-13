class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :order_id
      t.integer :index
      t.string :path

      t.timestamps
    end
  end
end
