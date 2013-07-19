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

  def message_with_order(message, order = nil, user = nil)
    if user.openid != order.user_id
      text = "只能查询自己的订单。"
    elsif order
      text = order.to_s
    else
      text = "订单号错误。"
    end
    text += "\n\n输入订单号继续查询，输入【#】退出查询。"

    message_with_text(message, text)
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

  def process_image(message, url = "")
  	{
  		toUser: message['FromUserName'],
  		fromUser: message['ToUserName'],
  		type: 'news',
  		title: '明信片预览',
  		description: "输入【下单】送出明信片。点击下边【阅读全文】查看或修改订单详情。",
  		picurl: placeholder_image(message['PicUrl']),
  		url: url
  	}
  end

  def placeholder_image(url)	
  	width, height = rand(20) + 480, rand(20) + 320
  	"http://placekitten.com/#{width}/#{height}"
  end
end
