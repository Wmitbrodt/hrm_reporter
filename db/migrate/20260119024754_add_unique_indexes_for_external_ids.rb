class AddUniqueIndexesForExternalIds < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :external_id, unique: true
    add_index :hrm_sessions, :external_id, unique: true
  end
end
