class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.boolean :isadmin, null: false, default: false

      t.timestamps
    end
  end
end
