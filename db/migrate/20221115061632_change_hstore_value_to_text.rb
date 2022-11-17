class ChangeHstoreValueToText < ActiveRecord::Migration[7.0]
  def up
    change_column :settings, :values, :text
    change_column :users, :settings, :text
  end

  def down
    change_column :settings, :values, :hstore
    change_column :users, :settings, :hstore
  end
end
