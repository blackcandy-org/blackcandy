class RemoveActiveStorage < ActiveRecord::Migration[6.0]
  def change
    drop_table :active_storage_attachments, if_exists: true
    drop_table :active_storage_blobs, if_exists: true
  end
end
