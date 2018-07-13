require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'capistrano/stride/client'

namespace :stride do
  task :notify_deploy_failed do
    message = "#{fetch(:local_user, local_user).strip} cancelled deployment of #{fetch(:application)} to #{fetch(:stage)}."
    url = fetch(:stride_url)
    token = fetch(:stride_token)
    Capistrano::Stride::Client.execute(url, token, message, 'removed')
  end

  task :notify_deploy_started do
    commits = `git log --no-color --max-count=5 --pretty=format:' - %an: %s' --abbrev-commit --no-merges #{fetch(:previous_revision, "HEAD")}..#{fetch(:current_revision, "HEAD")}`
    message = "#{fetch(:local_user, local_user).strip} is deploying #{fetch(:application)} to #{fetch(:stage)} \n\n#{commits}"
    url = fetch(:stride_url)
    token = fetch(:stride_token)
    Capistrano::Stride::Client.execute(url, token, message)
  end

  task :notify_deploy_finished do
    message = "#{fetch(:local_user, local_user).strip} finished deploying #{fetch(:application)} to #{fetch(:stage)}."
    url = fetch(:stride_url)
    token = fetch(:stride_token)
    Capistrano::Stride::Client.execute(url, token, message, 'success')
  end

  before "deploy:updated", "stride:notify_deploy_started"
  after "deploy:finished", "stride:notify_deploy_finished"
  before "deploy:reverted", "stride:notify_deploy_failed"
end
