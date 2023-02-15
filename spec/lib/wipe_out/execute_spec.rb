RSpec.describe WipeOut::Execute do
  let(:comments_plan) do
    WipeOut.build_plan do
      relation :resource_files do
        on_execute ->(execution) { execution.record.destroy! }
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

    WipeOut.build_plan do
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

      before(:execution) do |execution|
        if execution.record.is_a?(User)
          execution.record.first_name = "deleted-name"
        end
      end
    end
  end

  context "when record is valid" do
    it "wipes out user" do
      user = create(:user, :with_comments, :with_dashboard)

      plan.execute(user)

      aggregate_failures("saves user") do
        expect(user).to be_persisted
        expect(user.changes).to be_empty
      end

      aggregate_failures("clears attributes") do
        expect(user.last_name).to eq(nil)
        expect(user.access_tokens).to eq(nil)
        expect(user.first_name).to eq("deleted-name")
      end

      aggregate_failures("uses custom strategies") do
        expect(user.reset_password_token).to eq("rest_password_123")
        expect(user.sign_in_count).to eq(0)
      end

      aggregate_failures("custom plans are used for relations") do
        expect(user.dashboard.reload.order).to be_nil
        expect(user.comments.first.resource_files).to be_empty
      end
    end
  end

  context "when record is invalid" do
    # This can happen when someone added new validations to the model
    # and a model no longers passes validations. It needs to immediately fail
    # otherwise there's a risk data won't be removed
    it "logs errors and doesn't save changes" do
      first_name = "test"
      user = create(:user, first_name: first_name)
      user.update_columns(confirmed_at: nil)

      plan.execute(user)
    rescue ActiveRecord::RecordInvalid => _e
      user.reload

      expect(user.first_name).to eq(first_name)
    end
  end

  context "with custom on_execute block" do
    it "saves even invalid data" do
      plan = WipeOut.build_plan do
        on_execute do |execution|
          execution.record.save(validate: false)
        end
        wipe_out :last_name, :access_tokens
      end
      first_name = "test"
      user = create(:user, first_name: first_name)
      user.update_columns(confirmed_at: nil)

      plan.execute(user)
      user.reload

      expect(user.first_name).to eq(first_name)
    end
  end

  describe "configuration" do
    it "allows to change defaults" do
      plan =
        WipeOut.build_plan do
          configure do |config|
            config.default_on_execute = ->(execution) do
              execution.record.destroy!
            end
          end

          ignore_all
        end
      user = create(:user)

      plan.execute(user)

      expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "included plans are sharing configuration from the top level" do
      changed_user_plan =
        WipeOut.build_plan do
          configure do |config|
            config.default_on_execute = ->(_execution) { raise "This shouldn't run" }
          end
        end
      plan =
        WipeOut.build_plan do
          wipe_out :first_name
          include_plan(changed_user_plan)
        end
      user = create(:user)

      plan.execute(user)

      expect(plan.config.default_on_execute).to eq(WipeOut.config.default_on_execute)
    end

    it "nested plans are sharing configuration from the top level" do
      comments_plan =
        WipeOut.build_plan do
          configure do |config|
            config.default_on_execute = ->(_execution) { raise "This shouldn't run" }
          end
        end
      plan =
        WipeOut.build_plan do
          wipe_out :first_name
          relation :comments, comments_plan
        end
      user = create(:user)

      plan.execute(user)

      expect(plan.config.default_on_execute).to eq(WipeOut.config.default_on_execute)
    end
  end

  describe "with plan unions" do
    it "selects a plan during execution" do
      comments_plan = WipeOut.build_plan do
        on_execute ->(execution) { execution.record.destroy! }
      end

      vip_comments_plan = WipeOut.build_plan do
        wipe_out :value do
          "comment"
        end
        ignore :resource_files
      end

      plan = WipeOut.build_plan do
        relation :comments, plans: [comments_plan, vip_comments_plan] do |record|
          (record.user.last_name == "VIP") ? vip_comments_plan : comments_plan
        end

        ignore :last_name, :confirmed_at, :dashboard,
          :sign_in_count, :reset_password_token, :access_tokens
      end

      user = create(:user, :with_comments)
      vip_user = create(:user, :with_comments, last_name: "VIP")

      plan.execute(user)
      plan.execute(vip_user)

      user.reload
      vip_user.reload

      aggregate_failures "removes comments for normal user" do
        expect(user.comments).to eq([])
      end

      aggregate_failures "overwrites content in comments for vip user" do
        expect(vip_user.comments.count).to eq(vip_user.comments.count)
        expect(vip_user.comments.map(&:value)).to eq(%w[comment comment])
      end
    end
  end
end
