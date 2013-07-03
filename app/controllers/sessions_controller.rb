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
  	# parser = Nori.new
  	@receive_message = Hash.from_xml(request.body.read)["xml"]

  	case @receive_message['MsgType']
  	when "text"
	  	@send_message = process_text(@receive_message)
	  	render :text
  	when "image"
  		@send_message = process_image(@receive_message)
  		render :image
  	end
  end

  def process_text(message)
  	receive_content = message['Content']
  	user_id = message['FromUserName']
  	order = Order.where(user_id: user_id).last
  	text = nil
  	if receive_content == "下单" 
  		order = Order.create(user_id: user_id)
  		text = order.proceed!
  	elsif order.nil?
	  	text = "对不起哟，我们正在开发新功能~ 下边是您说了的话。我们还是能看到的!\n#{receive_content}"
	elsif order < :accepted or order < :rejected
		if receive_content != "><"
			text = order.proceed!
		else
			order.reinput!
		end
	end

  	message_with_text(message, text)
  end

  def message_with_text(message, text)
  	{
		toUser: message['FromUserName'],
		fromUser: message['ToUserName'],
		type: 'text',
		content: text
  	}
  end

  def process_image(message)
  	{
		toUser: message['FromUserName'],
		fromUser: message['ToUserName'],
		type: 'news',
		title: '随机的小猫图',
		description: '功能还在开发中..',
		picurl: do_process_image(message['PicUrl']),
		url: ''
  	}
  end

  def do_process_image(url)
	# image = MiniMagick::Image.open(url)
	# image.combine_options do |c|
	#   c.sample "50%"
	#   c.rotate "-90"
	# end
	# image.write "output.jpg"  	
	width, height = rand(20) + 640, rand(20) + 320
	"http://placekitten.com/#{width}/#{height}"
  end
end
