class AddSalesPriceToUser < ActiveRecord::Migration
  def change
  	add_column :users, :sales_price, :integer
  end
end
