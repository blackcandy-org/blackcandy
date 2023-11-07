class RemoveApiTokenFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :api_token, :string
  end
end
