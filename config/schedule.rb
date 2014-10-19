# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
require 'yaml'
Rails_root = path #File.dirname(__FILE__)+'/..'
set :environment, 'production'
set :output, {
    :error    => "#{Rails_root}/log/error.log",
    :standard => "#{Rails_root}/log/cron.log"
}

every 5.minute do
#  PushNotificationFactory.pushNotificationBot
  runner "PushNotificationFactory.pushNotificationBot", :environment => "production"
  #puts 'asdasdasd', :environment => "development"
  #command 'echo "asdasdasd"', :environment => "development"
end
