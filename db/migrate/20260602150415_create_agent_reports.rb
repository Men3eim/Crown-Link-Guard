class CreateAgentReports < ActiveRecord::Migration[6.0]
  def change
    create_table :agent_reports do |t|
      t.text :original_url
      t.text :normalized_url
      t.string :domain
      t.text :ticket_url
      t.string :ticket_id
      t.string :agent_email
      t.string :agent_name
      t.text :agent_note
      t.integer :risk_score, null: false, default: 0
      t.string :risk_level, null: false, default: "safe"
      t.jsonb :reasons, null: false, default: []
      t.string :status, null: false, default: "pending"
      t.string :reviewer_email
      t.text :reviewer_note
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :agent_reports, :created_at
    add_index :agent_reports, :domain
    add_index :agent_reports, :status
    add_index :agent_reports, :agent_email
  end
end
