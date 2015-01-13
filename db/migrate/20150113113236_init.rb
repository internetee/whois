class Init < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.text   :body
      t.timestamps null: false
    end
  end
end
