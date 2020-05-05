RSpec.describe WipeOut::Execute do
  CommentsWipeOutPlan = let(:comments_plan) do
    WipeOut.build_plan do
      relation :resource_files do
        destroy!
      end
    end
  end
  let(:dashboard_plan) do
    WipeOut.build_plan do
      wipe_out :order
      ignore :name
    end
  end

  let(:plan) do
    comments_plan = self.comments_plan
    dashboard_plan = self.dashboard_plan

    WipeOut.build_root_plan(User) do
      wipe_out :last_name, :access_tokens

      # Custom strategy
      wipe_out :sign_in_count, strategy: WipeOut::AttributeStrategies::ConstValue.new(0)
      # Inline custom strategy
      wipe_out :reset_password_token do
        "rest_password_123"
      end

      relation :comments, comments_plan
      relation :dashboard, dashboard_plan

      ignore :confirmed_at

      before_save do |record|
        record.first_name = "deleted-name"
      end
    end.plan
  end

  let(:user) { create(:user, :with_comments, :with_dashboard) }

  let(:execute) do
    described_class.call(plan, user, [])
  end

  it "saves record" do
    execute
    expect(user).to be_persisted
    expect(user.changes).to be_empty
  end

  it "clears attributes" do
    execute
    expect(user.last_name).to be_nil
    expect(user.access_tokens).to be_nil
  end

  it "uses const value strategy" do
    expect { execute }.to change(user, :sign_in_count).to eq 0
  end

  it "uses inline strategy" do
    expect { execute }.to change(user, :reset_password_token).to eq "rest_password_123"
  end

  it "supports plans union" do
    execute
    expect(user.dashboard.reload.order).to be_nil
    expect(user.comments.first.resource_files).to be_empty
  end

  it "calls custom callback" do
    execute
    expect(user.first_name).to eq "deleted-name"
  end

  context "when record is invalid" do
    before do
      user.update_column :confirmed_at, nil
    end

    it "logs the problem" do
      allow(Rails.logger).to receive(:info)
      execute
      expect(Rails.logger).to have_received(:info).with(start_with("[wipe_out-invalid-record]"))
    end

    it "saves record" do
      execute
      expect(user).to be_persisted
      expect(user.changes).to be_empty
    end
  end

  context "with plugins" do
    plugin_class = Class.new(WipeOut::PluginBase) do
      def initialize(spy)
        @spy = spy
      end

      def around_each(plan, record)
        @spy.call("before", plan, record)
        yield
        @spy.call("after", plan, record)
      end
    end

    let(:spy1) { spy }
    let(:spy2) { spy }

    let(:plugin1) { plugin_class.new(spy1) }
    let(:plugin2) { plugin_class.new(spy2) }

    let(:execute) do
      described_class.call(plan, user, [plugin1, plugin2])
    end

    it "calls each plugin's #around_each for root plan and each nested plans" do
      execute
      expect(spy1).to have_received(:call).exactly(6).times
      expect(spy2).to have_received(:call).exactly(6).times
    end

    context "with nested plugins" do
      let(:spy3) { spy }

      let(:plugin3) { plugin_class.new(spy3) }

      let(:project_component_plan) do
        plugin3 = self.plugin3
        WipeOut.build_root_plan(User) do
          plugins plugin3
          wipe_out :first_name, strategy: WipeOut::AttributeStrategies::Randomize.new
        end
      end

      it "doesn't call nested plugin's #around_each for nested plans" do
        execute
        expect(spy3).not_to have_received(:call)
      end
    end
  end
end
