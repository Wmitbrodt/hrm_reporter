class CreateHrmSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :hrm_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :imported_created_at
      t.integer :duration_secs
      t.bigint :external_id
      t.integer :min_bpm
      t.integer :max_bpm
      t.decimal :avg_bpm
      t.integer :total_duration_secs
      t.bigint :weighted_bpm_sum
      t.integer :zone1_secs
      t.integer :zone2_secs
      t.integer :zone3_secs
      t.integer :zone4_secs
      t.jsonb :chart_points

      t.timestamps
    end

    add_index :hrm_sessions, :external_id, unique: true
    add_index :hrm_sessions, :imported_created_at
  end
end
