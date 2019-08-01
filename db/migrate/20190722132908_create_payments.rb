class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :address
      t.integer :amount
      t.string :txid
      t.integer :wallet
      t.integer :height
      t.integer :confirm

      t.timestamps
    end
  end
end
