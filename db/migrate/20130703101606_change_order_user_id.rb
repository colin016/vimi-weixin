class ChangeOrderUserId < ActiveRecord::Migration
  def up
  	change_table :orders do |t|
      t.change :user_id, :string
    end
  end

  def down
  end
end
