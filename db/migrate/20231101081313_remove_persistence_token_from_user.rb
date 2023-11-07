class RemovePersistenceTokenFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :persistence_token, :string
  end
end
