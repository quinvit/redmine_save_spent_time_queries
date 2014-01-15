class CreateSpentTimeQueries < ActiveRecord::Migration
  def change
    create_table :spent_time_queries do |t|

      t.string :name

      t.string :query

      t.boolean :is_public

      t.integer :user_id

    end

  end
end
