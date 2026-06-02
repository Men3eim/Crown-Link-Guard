class CreateBlockedDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_domains do |t|
      t.string :domain, null: false
      t.string :severity, null: false, default: "high"
      t.text :reason
      t.string :created_by
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :blocked_domains, :domain, unique: true
    add_index :blocked_domains, :severity
    add_index :blocked_domains, :active
  end
end
