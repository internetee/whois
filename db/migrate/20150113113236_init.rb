class Init < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.text   :whois_body
      t.timestamps null: false
    end

    add_index :domains, :name
  end
end
