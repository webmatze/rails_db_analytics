class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
