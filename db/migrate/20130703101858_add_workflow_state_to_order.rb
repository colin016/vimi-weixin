class AddWorkflowStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :workflow_state, :string
  end
end
