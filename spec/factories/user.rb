FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    confirmed_at { Date.new }

    trait :with_comments do
      comments { build_list(:comment, 2) }
    end

    trait :with_dashboard do
      dashboard { build(:dashboard) }
    end
  end
end
