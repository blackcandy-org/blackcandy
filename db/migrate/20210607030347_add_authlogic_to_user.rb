class AddAuthlogicToUser < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :password_digest, :crypted_password
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_index :users, :persistence_token, unique: true
  end
end
