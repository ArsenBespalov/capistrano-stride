module Capistrano::Stride::Client
  def self.execute(stride_url, stride_token, message = '', status = 'inprogress')
    @status = status
    @message = message
    if status == 'inprogress'
      @status_text = 'Started'
    elsif status == 'success'
      @status_text = 'Successful'
    elsif status == 'removed'
      @status_text = 'Failed'
    else
      @status = 'default'
      @status_text = 'Unknown'
    end

    uri = URI.parse(stride_url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    header = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{stride_token}"
    }
    req = Net::HTTP::Post.new(uri.path, header)
    req.body = body.to_json
    https.request(req)
  end

  def self.body
    {
        body: {
            version: 1,
            type: 'doc',
            content: [
                {
                    type: 'applicationCard',
                    attrs: {
                        text: @message,
                        collapsible: true,
                        title: {
                            text: 'Deployment Status'
                        },
                        description: {
                            text: @message
                        },
                        details: [
                            {
                                lozenge: {
                                    text: @status_text,
                                    appearance: @status
                                }
                            }
                        ]
                    }
                }
            ]
        }
    }
  end
end
