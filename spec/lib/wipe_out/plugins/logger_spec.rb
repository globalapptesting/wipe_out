RSpec.describe WipeOut::Plugins::Logger do
  context "when relation has a single wipe out plan" do
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

    it "logs all executions for all records, even from relations" do
      logger = double(Logger)
      logged_messages = []
      allow(logger).to receive(:debug) { |log| logged_messages << log }
      user = create(:user, :with_comments)
      first_comment = user.comments.first
      second_comment = user.comments.second
      plan.config.logger = logger

      plan.execute(user)

      expect(user.comments).to eq([first_comment, second_comment])
      expect(logged_messages).to match([
        "[WipeOut] start plan=Plan(attributes=[:last_name, :access_tokens])",
        "[WipeOut] executing plan=Plan(attributes=[:last_name, :access_tokens]) record_class=User id=#{user.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{first_comment.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{first_comment.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{second_comment.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{second_comment.id}",
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

  context "when relation has multiple wipe out plans (plans union)" do
    it "logs all executions for all records, even from relations" do
      comments_plan = WipeOut.build_plan do
        relation :resource_files do
          on_execute { |execution| execution.record.destroy! }
        end
      end

      vip_comments_plan = WipeOut.build_plan do
        ignore :resource_files
      end

      plan = WipeOut.build_plan do
        plugin WipeOut::Plugins::Logger

        wipe_out :last_name, :access_tokens

        relation :comments, plans: [comments_plan, vip_comments_plan] do |record|
          record.value.starts_with?("[SPECIAL]") ? vip_comments_plan : comments_plan
        end
      end

      logger = double(Logger)
      logged_messages = []
      allow(logger).to receive(:debug) { |log| logged_messages << log }
      user = create(:user)
      create_list(:comment, 2, user: user)
      create_list(:comment, 2, user: user, value: "[SPECIAL] Comment")
      plan.config.logger = logger

      plan.execute(user)

      expect(logged_messages).to match([
        "[WipeOut] start plan=Plan(attributes=[:last_name, :access_tokens])",
        "[WipeOut] executing plan=Plan(attributes=[:last_name, :access_tokens]) record_class=User id=#{user.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.first.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.first.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.second.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.second.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.third.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.third.id}",
        "[WipeOut] executing plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.fourth.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[]) record_class=Comment id=#{user.comments.fourth.id}",
        "[WipeOut] wiped out plan=Plan(attributes=[:last_name, :access_tokens]) record_class=User id=#{user.id}",
        "[WipeOut] completed plan=Plan(attributes=[:last_name, :access_tokens])"
      ])
    end
  end
end
