class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, null: false, default: "admin"
      t.string :ad_username
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
