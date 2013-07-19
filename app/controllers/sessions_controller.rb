# encoding: utf-8

require 'digest/sha1'

class SessionsController < ApplicationController
  def entry
  	my_params = {token: 'molitown'}
  	my_params.merge! params.select { |k, v| k.to_s.match /timestamp|nonce/ }
  	text = my_params.values.sort.join
  	hash_text = Digest::SHA1.hexdigest text

  	render text: params['echostr'] if params['signature'] == hash_text
  end

  def talk
    m = sender.process_message(receive_message)
    p receive_message
    render_message(m)
  end

  def render_message(m)
    if m[:type] == 'text' 
      @send_message = message_with_text(receive_message, m[:content])
      render :text
    else
    end
  end

  def receive_message
    xml = request.body.read
    @receive_message ||= WxTextMessage.new(xml)
  end

  def sender
    @user ||= User.find_or_create_by_openid(receive_message['FromUserName'])
  end

  def message_with_text(message, text = nil)
    default_reply = "系统正在升级中，小微会有些胡言乱语，请谅解~\n\n您刚刚说：#{message['Content']}"

  	{
  		toUser: message['FromUserName'],
  		fromUser: message['ToUserName'],
  		type: 'text',
  		content: text || default_reply
  	}
  end
end
