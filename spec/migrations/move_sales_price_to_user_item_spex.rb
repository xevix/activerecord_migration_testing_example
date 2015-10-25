require "rails_helper.rb"
require Rails.root.join("db/migrate/20151025080100_move_sales_price_to_user_item.rb")

describe MoveSalesPriceToUserItem do
  let(:migrations_paths) { Rails.root.join("db/migrate") }
  let(:previous_version) { 20151025075912 }
  let(:test_version) { 20151025080100 }

  # Base fixtures
  let(:user_base) { FactoryGirl.create(:user) }
  let(:user_items_base) { FactoryGirl.create_list(:user_item, 2, user: user) << FactoryGirl.create(:user_item, user: user) }
  let(:itemless_user_base) { FactoryGirl.create(:user) }
  let(:nil_salesprice_user_base) { FactoryGirl.create(:user) }

  # Fixtures loaded at MUT - 1
  let(:user_pre) { User.find(user_base.id) }
  let(:itemless_user_pre) { User.find(itemless_user_base.id) }

  # Fixtures loaded at MUT
  let(:user) { User.find(user_base.id) }
  let(:user_items) { user.user_items }
  let(:itemless_user) { User.find(itemless_user_base.id) }
  let(:nil_salesprice_user) { User.find(nil_salesprice_user_base.id) }

  before(:each) do
    ## 1. Create fixtures
    user_items_base
    itemless_user_base
    ## 2. Migrate down to previous version
    ActiveRecord::Migrator.migrate(migrations_paths, previous_version)
    # Reset column info of relevant tables
    User.reset_column_information
    UserItem.reset_column_information
    ## 3. Ensure data integrity
    expect(User.column_names).to include("sales_price")
    expect(UserItem.column_names).not_to include("sales_price")
    user_pre
    itemless_user_pre
    expect(user_items_base.first.sales_price).to eq(user_pre.sales_price)
    expect(itemless_user_pre.sales_price).to be_nil
    # Create an item for the nil salesprice user
    UserItem.create(user: nil_salesprice_user, item: FactoryGirl.create(:item))
    ## 4. Migrate to the Migration Under Test (MUT)
    ActiveRecord::Migrator.migrate(migrations_paths, test_version)
    # Reset column info of relevant tables
    User.reset_column_information
    UserItem.reset_column_information
  end

  # 5. RSpec testing
  describe ".up" do
    it "migrates without data loss" do
      expect(User.column_names).not_to include("sales_price")
      expect(UserItem.column_names).to include("sales_price")
      expect(user_pre.sales_price).to be > 0
      expect(user_items.collect(&:sales_price).uniq).to eq([user_pre.sales_price])
      expect(nil_salesprice_user.user_items.collect(&:sales_price).uniq).to eq([0])
    end
  end

end