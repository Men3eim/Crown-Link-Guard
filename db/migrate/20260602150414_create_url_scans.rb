class CreateUrlScans < ActiveRecord::Migration[6.0]
  def change
    create_table :url_scans do |t|
      t.text :original_url
      t.text :normalized_url
      t.string :domain
      t.integer :risk_score, null: false, default: 0
      t.string :risk_level, null: false, default: "safe"
      t.string :action_taken, null: false, default: "allowed"
      t.jsonb :reasons, null: false, default: []
      t.string :agent_email
      t.string :agent_name
      t.text :ticket_url
      t.string :ticket_id
      t.text :user_agent
      t.string :device_name
      t.string :source

      t.timestamps
    end

    add_index :url_scans, :created_at
    add_index :url_scans, :domain
    add_index :url_scans, :risk_level
    add_index :url_scans, :action_taken
    add_index :url_scans, :agent_email
  end
end
