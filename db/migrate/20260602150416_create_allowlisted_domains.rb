class CreateAllowlistedDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :allowlisted_domains do |t|
      t.string :domain, null: false
      t.boolean :allow_subdomains, null: false, default: false
      t.text :notes
      t.string :created_by
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :allowlisted_domains, :domain, unique: true
    add_index :allowlisted_domains, :active
  end
end
