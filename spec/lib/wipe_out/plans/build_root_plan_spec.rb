RSpec.describe WipeOut, ".build_plan" do
  let(:root_plan) do
    described_class.build_plan(User) do
      wipe_out :first_name, :last_name

      relation :comments do
        wipe_out :value

        relation :resource_files do
          destroy!
        end
      end
    end
  end

  let(:plan) { root_plan }

  # rubocop:disable RSpec/MultipleExpectations
  it "builds nested plan" do
    expect(plan.attributes.keys).to eq [:first_name, :last_name]

    comments_plan = plan.relations[:comments]
    expect(comments_plan.attributes.keys).to eq [:value]
    expect(comments_plan.destroy?).to eq false

    resource_files_plan = comments_plan.relations[:resource_files]
    expect(resource_files_plan.attributes.keys).to eq []
    expect(resource_files_plan.destroy?).to eq true
  end
  # rubocop:enable RSpec/MultipleExpectations
end
