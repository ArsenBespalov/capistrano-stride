namespace :stride do
  task :notify_deploy_failed do
    message = "#{fetch(:local_user, local_user).strip} cancelled deployment of #{fetch(:application)} to #{fetch(:stage)}."

    message_body = {
        version: 1,
        type: "doc",
        content: [
            {
                type: "panel",
                attrs: {
                    panelType: "warning"
                },
                content: [
                    {
                        type: "paragraph",
                        content: [
                            {
                                type: "text",
                                text: message
                            }
                        ]
                    }
                ]
            }
        ]
    }

    fetch(:client).send_message(message_body)
  end

  task :notify_deploy_started do
    commits = `git log --no-color --max-count=5 --pretty=format:' - %an: %s' --abbrev-commit --no-merges #{fetch(:previous_revision, "HEAD")}..#{fetch(:current_revision, "HEAD")}`
    # commits.gsub!("\n", "<br />")
    message = "#{fetch(:local_user, local_user).strip} is deploying #{fetch(:application)} to #{fetch(:stage)} <br />"

    message_body = {
        version: 1,
        type: "doc",
        content: [
            {
                type: "panel",
                attrs: {
                    panelType: "info"
                },
                content: [
                    {
                        type: "paragraph",
                        content: [
                            {
                                type: "text",
                                text: message
                            },
                            {
                                type: "text",
                                text: commits,
                                marks: [
                                    {
                                        type: "code"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }

    fetch(:client).send_message(message_body)
  end

  task :notify_deploy_finished do
    message = "#{fetch(:local_user, local_user).strip} finished deploying #{fetch(:application)} to #{fetch(:stage)}."

    message_body = {
        version: 1,
        type: "doc",
        content: [
            {
                type: "panel",
                attrs: {
                    panelType: "note"
                },
                content: [
                    {
                        type: "paragraph",
                        content: [
                            {
                                type: "text",
                                text: message
                            }
                        ]
                    }
                ]

            }
        ]
    }

    fetch(:client).send_message(message_body)
  end

  before "deploy:updated", "stride:notify_deploy_started"
  after "deploy:finished", "stride:notify_deploy_finished"
  before "deploy:reverted", "stride:notify_deploy_failed"
end

namespace :load do
  task :defaults do
    require 'stride'

    set(:client, -> {Stride::Client.new(fetch(:cloud_id), fetch(:conversation_id))})
  end
end