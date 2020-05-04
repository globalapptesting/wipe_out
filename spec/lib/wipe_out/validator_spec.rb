RSpec.describe WipeOut::Validator do
  let(:root_plan) do
    WipeOut.build_root_plan(User) do
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

  let(:errors) { described_class.call(root_plan.plan, User, config: root_plan.config) }

  it "validates plan" do
    expect(errors).to eq [
      "User plan is missing attributes: :reset_password_token",
      "User plan has extra attributes: :abc",
      "User relation is missing: dashboard",
      "User has invalid relation: :what"
    ]
  end
end
