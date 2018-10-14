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
every 2.hours do
  command "RAILS_ENV=production bundle exec ~/www/btc/current/bin/delayed_job -n4 restart"
end

every 12.hours do
  rake 'g:sitemap'
  rake 'g:mipmap'
  command "echo 'flush_all' | nc localhost 11211"
end

every 30.minutes do
  runner "SiteConfig.clear_index_cache"
end

every 12.hours do
  runner "SiteConfig.clear_html_cache"
end

every 12.hours do
  rake 'baidu:notify_mip'
end

every 1.day, at: '01:00 am' do
  # runner 'UserCreditLog.log_everyone!'
  runner 'UserCreditLog.init!'
end

# every 2.hours do
#   rake 'clear:cache'
# end

# every 1.hours do
#   rake 'tmp:clear'
# end
