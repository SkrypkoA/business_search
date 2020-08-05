class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :business_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :place_id
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
