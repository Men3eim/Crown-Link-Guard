class CreateAuditLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_logs do |t|
      t.string :user_email
      t.string :action, null: false
      t.string :record_type
      t.integer :record_id
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :audit_logs, :created_at
    add_index :audit_logs, :user_email
    add_index :audit_logs, [:record_type, :record_id]
  end
end
