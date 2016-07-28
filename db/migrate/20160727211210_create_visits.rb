class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :shortened_url_id, null: false
      t.integer :user_id, null: false
      t.integer :times_visited, null: false
      t.timestamps null: false
    end
  end
end
