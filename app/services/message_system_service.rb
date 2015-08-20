require 'rest_client'

module MessageSystemService
  extend self
  # MessageSystemService
  # 系统通信服务接口，使用它来向用户发送实时消息

  # 私有消息接口，1 对 1 聊天
  def push_message(author_id, target_id, content, options = {})
    type = options[:type] || 'info'
    key = options[:key]
    to = options[:to] || [author_id, target_id]

    channel_id = 'p:' + [author_id.to_s, target_id.to_s].sort.join(':')
    msg = {
      senderId: author_id,
      channelId: channel_id,
      content: content,
      type: type,
      to: to.to_json,
      key: key
    }

    send('messages', msg )
  end

  # 向用户发送命令
  def push_command(author_id, target_id, cmd)
    msg = {
      senderId: author_id,
      to: [target_id].to_json,
      content: cmd
    }

    send('commands', msg )
  end

  def send(channel, msg)
    url = File.join(pusher_url, channel)
    msg.merge! token: options.pusher_token
    RestClient.post url, msg, token: options.pusher_token
  end

  def send_read_message(author_id, target_id)
    channel_id = 'p' + target_id.to_s
    msg = {
      userId: author_id,
      channelId: channel_id
    }

    send('read_channel', msg )
  end

  private

  def options
    Settings.pusher
  end

  def pusher_url
    options.pusher_url
  end
end
