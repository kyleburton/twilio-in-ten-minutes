class CreateCallSessions < ActiveRecord::Migration
  def self.up
    create_table :call_sessions do |t|
      t.string :session_id,              :null => false
      t.string :caller_number,           :null => false
      t.string :workflow_name,           :null => false
      t.string :state,                   :null => false
      t.text   :workflow_internal_state, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :call_sessions
  end
end
