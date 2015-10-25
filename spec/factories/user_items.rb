FactoryGirl.define do
  sequence(:sales_price_generator) { |n| 1 + n }

  factory :user_item do
    user
    item
    sales_price { generate(:sales_price_generator) }
  end

end
