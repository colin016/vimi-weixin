# encoding: utf-8

require 'digest/sha1'

class SessionsController < ApplicationController
  def entry
  	my_params = {token: 'molitown'}
  	my_params.merge! params.select { |k, v| k.to_s.match /timestamp|nonce/ }
  	text = my_params.values.sort.join
  	hash_text = Digest::SHA1.hexdigest text

  	# render :json => {params: my_params.values.sort, signature: params['signature'], my_signature: hash_text}
  	render text: params['echostr'] if params['signature'] == hash_text
  end

  def talk
  	@receive_message = Hash.from_xml(request.body.read)["xml"]
    user = @receive_message['FromUserName']
    order = nil

  	case @receive_message['MsgType']
  	when "text"
      content = @receive_message['Content']
      order = Order.where(user_id: user).last
      order = nil if order.nil? or order.current_state == :accepted or order.current_state == :rejected
      order.proceed!(content) if order
  	when "image"
      order = Order.create(user_id: user)
      order.proceed!
    end
    
    if order and order.current_state == :submiting
      @send_message = process_image(@receive_message, edit_order_url(order))
      render :image
    else
      @send_message = message_with_text(@receive_message, order && order.state_in_words)
      render :text
    end
  end

  def message_with_text(message, text)
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
