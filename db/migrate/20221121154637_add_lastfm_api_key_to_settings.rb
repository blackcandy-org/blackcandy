class AddLastfmApiKeyToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :lastfm_api_key, :string
  end
end
