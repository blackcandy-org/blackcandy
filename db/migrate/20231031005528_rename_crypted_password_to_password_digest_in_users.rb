class RenameCryptedPasswordToPasswordDigestInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :crypted_password, :password_digest
  end
end
