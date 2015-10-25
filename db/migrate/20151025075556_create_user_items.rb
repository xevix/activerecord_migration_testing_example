class CreateUserItems < ActiveRecord::Migration
  def change
    create_table :user_items do |t|
    	t.belongs_to :user
    	t.belongs_to :item

      t.timestamps null: false
    end
  end
end
