class RenamePasswordSaltToDeprecatedPasswordSaltInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :password_salt, :deprecated_password_salt
  end
end
