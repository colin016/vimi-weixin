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
  	@receive_message = Hash.from_xml(request.body.read)["xml"]
    user = User.find_or_create_by_openid(@receive_message['FromUserName'])
    order = nil

    if @receive_message['Content'] == '#'
      user.exit!

      @send_message = message_with_text(@receive_message, user.state_in_words)
      render :text
    elsif @receive_message['MsgType'] == 'image'
      user.order!
      order = Order.create(user_id: user.openid)
      order.proceed!

      @send_message = message_with_text(@receive_message, order.state_in_words)
      render :text
    elsif user.current_state == :ordering
      order = Order.where(user_id: user.openid).last
      content = @receive_message['Content']
      order.proceed!(content)
      user.exit! if order.current_state == :accepted

      if order.current_state == :submiting
        @send_message = process_image(@receive_message, edit_order_url(order))
        render :image
      else
        @send_message = message_with_text(@receive_message, order.state_in_words)
        render :text
      end
    elsif @receive_message['Content'] == '查订单'
      user.query!
      @send_message = message_with_text(@receive_message, "请输入您的订单号：")
      render :text
    elsif user.current_state == :querying
      order_id = @receive_message['Content']
      order = Order.find_by_id(order_id)

      @send_message = message_with_order(@receive_message, order, user)
      render :text
    else
      @send_message = message_with_text(@receive_message, user.state_in_words)
      render :text
    end
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
