class CreateSecuritySettings < ActiveRecord::Migration[6.0]
  def change
    create_table :security_settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :updated_by

      t.timestamps
    end

    add_index :security_settings, :key, unique: true
  end
end
