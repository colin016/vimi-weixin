class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :openid
      t.string :workflow_state

      t.timestamps
    end
  end
end
