FactoryBot.define do
  factory :comment do
    value { "Comment" }

    trait :with_resource_files do
      resource_files { build_list(:resource_file, 1) }
    end
  end
end
