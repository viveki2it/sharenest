class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :referral_code
      t.integer :referrer_id
      t.string :first_name

      t.timestamps null: false
    end
  end
end
