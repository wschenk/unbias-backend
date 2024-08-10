class Article < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.references :account, foreign_key: true
      t.string :state
      t.string :url
      t.text :body
      t.text :summary
      t.text :analysis
      t.timestamps
    end
  end
end
