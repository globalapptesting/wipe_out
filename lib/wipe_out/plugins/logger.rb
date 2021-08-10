module WipeOut
  module Plugins
    # Logger plugin module to be used by including it in the plan.
    # When it runs, it prints out debug logs using `WipeOut::Config.logger`
    #
    # @example
    #     WipeOut.build_plan do
    #       plugin WipeOut::Plugins::Logger
    #       wipe_out :name
    #     end
    #
    # @example
    #     [WipeOut] start plan=Plan(User, attributes=[:name])
    #     [WipeOut] executing plan=Plan(User, attributes=[:name]) record_class=User id=#{user.id}
    #     [WipeOut] wiped out plan=Plan(User, attributes=[:name]) record_class=User id=#{user.id}
    #     [WipeOut] completed plan=Plan(User, attributes=[:name])
    #
    module Logger
      include WipeOut::Plugin

      before(:plan) do |execution|
        execution.config.logger.debug("[WipeOut] start plan=#{execution.plan.inspect}")
      end

      after(:plan) do |execution|
        execution.config.logger.debug("[WipeOut] completed plan=#{execution.plan.inspect}")
      end

      before(:execution) do |execution|
        execution.config.logger.debug(
          "[WipeOut] executing plan=#{execution.plan.inspect} " \
          "record_class=#{execution.record.class} id=#{execution.record.id}"
        )
      end

      after(:execution) do |execution|
        execution.config.logger.debug("[WipeOut] wiped out plan=#{execution.plan.inspect} " \
          "record_class=#{execution.record.class} id=#{execution.record.id}")
      end
    end
  end
end
