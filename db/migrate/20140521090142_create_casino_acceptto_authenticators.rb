class CreateCasinoAccepttoAuthenticators < ActiveRecord::Migration
  def change
    create_table :casino_acceptto_authenticators do |t|
      t.integer :user_id
      t.string :token
      t.boolean :authenticated
      t.timestamps
    end
  end
end
