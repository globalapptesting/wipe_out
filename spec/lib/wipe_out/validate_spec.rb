RSpec.describe WipeOut::Validate do
  let(:root_plan) do
    WipeOut.build_plan(User) do
      wipe_out :first_name, :last_name, :access_tokens, :confirmed_at, :sign_in_count, :abc

      relation :comments do
        wipe_out :value
        ignore :user_id

        relation :resource_files do
          destroy!
        end
      end

      relation :what do
      end
    end
  end

  it "validates plan" do
    expect(root_plan.validation_errors).to eq [
      "User plan is missing attributes: :reset_password_token",
      "User plan has extra attributes: :abc",
      "User relation is missing: dashboard",
      "User has invalid relation: :what"
    ]
  end
end
