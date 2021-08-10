RSpec.describe WipeOut::Validate do
  it "validates plan" do
    plan =
      WipeOut.build_plan do
        wipe_out :first_name, :last_name, :access_tokens, :confirmed_at, :sign_in_count, :abc

        relation :comments do
          wipe_out :value
          ignore :user_id

          relation :resource_files do
            on_execute ->(execution) { execution.record.destroy! }
            ignore_all
          end
        end

        relation :what do
        end
      end

    expect(plan.validate(User).errors).to eq([
      "User plan is missing attributes: :reset_password_token",
      "User plan has extra attributes: :abc",
      "User relation is missing: :dashboard",
      "User has invalid relation: :what"
    ])
  end

  it "allows to ignore all columns, useful when custom execution block is used" do
    plan = WipeOut.build_plan do
      ignore_all
    end

    expect(plan.validate(User).errors).to eq([])
  end
end
