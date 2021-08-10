RSpec.describe WipeOut::Plugins::Logger do
  let(:plan) do
    WipeOut.build_plan do
      plugin WipeOut::Plugins::Logger

      wipe_out :last_name, :access_tokens

      relation :comments do
        relation :resource_files do
          on_execute { |execution| execution.record.destroy! }
        end
      end
    end
  end

  it "logs all executions for all records, even from relations", :aggregate_failures do
    logger = double(Logger)
    logged_messages = []
    allow(logger).to receive(:debug) { |log| logged_messages << log }
    user = create(:user, :with_comments)
    comment = user.comments.first
    plan.config.logger = logger

    plan.execute(user)

    expect(user.comments).to eq([comment])
    expect(logged_messages).to match([
      "[WipeOut] start plan=Plan(attributes=[:last_name, :access_tokens])",
      "[WipeOut] executing plan=Plan(attributes=[:last_name, :access_tokens]) record_class=User id=#{user.id}",
      "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{comment.id}",
      "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{comment.id}",
      "[WipeOut] wiped out plan=Plan(attributes=[:last_name, :access_tokens]) record_class=User id=#{user.id}",
      "[WipeOut] completed plan=Plan(attributes=[:last_name, :access_tokens])"
    ])
  end

  describe "nested root plans with plugins" do
    it "uses plugin only from top level root plan that's executed" do
      user_plan = WipeOut.build_plan do
        plugin WipeOut::Plugins::Logger
        wipe_out :last_name, :access_tokens
        ignore :comments
      end
      user_basic_plan = WipeOut.build_plan do
        include_plan(user_plan)
        wipe_out :last_name
        ignore :comments, :access_tokens
      end
      logger = double(Logger)
      logged_messages = []
      user_basic_plan.config.logger = logger
      allow(logger).to receive(:debug) { |log| logged_messages << log }

      plan.execute(create(:user))

      expect(logged_messages).to match([])
    end
  end
end
