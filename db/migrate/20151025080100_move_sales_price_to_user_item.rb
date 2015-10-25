class MoveSalesPriceToUserItem < ActiveRecord::Migration
  def up
    add_column :user_items, :sales_price, :integer, null: false, default: 0
    UserItem.reset_column_information

    UserItem.includes(:user).each do |user_item|
      user_item.sales_price = user_item.user.sales_price || 0
      user_item.save!
    end

    remove_column :users, :sales_price
  end

  def down
    add_column :users, :sales_price, :integer
    User.reset_column_information

    User.includes(:user_items).each do |user|
      # Best-effort recovery. Grab the sales_price of the first if any.
      user.sales_price = user.user_items.first.try(:sales_price)
      user.save!
    end

    remove_column :user_items, :sales_price
  end
end
