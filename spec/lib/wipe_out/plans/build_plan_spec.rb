RSpec.describe WipeOut, ".build_plan" do
  it "builds nested plan", :aggregate_failures do
    built_plan =
      described_class.build_plan do
        wipe_out :first_name, :last_name

        relation :comments do
          wipe_out :value

          relation :resource_files do
            on_execute ->(execution) { execution.record.destroy! }
            ignore_all
          end
        end
      end

    plan = built_plan.plan

    expect(plan.attributes.keys).to eq %i[first_name last_name]

    comments_plan = plan.relations[:comments]
    expect(comments_plan.attributes.keys).to eq [:value]

    resource_files_plan = comments_plan.relations[:resource_files]
    expect(resource_files_plan.attributes.keys).to eq []
  end
end
