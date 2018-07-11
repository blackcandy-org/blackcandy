class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :is_admin, default: false
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
