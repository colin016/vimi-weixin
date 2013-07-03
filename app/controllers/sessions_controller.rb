# encoding: utf-8

require 'digest/sha1'
require 'mini_magick'

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
  	{
		toUser: message['FromUserName'],
		fromUser: message['ToUserName'],
		type: 'text',
		content: "对不起哟，我们正在开发新功能~ 下边是您说了的话。我们还是能看到的!\n#{message['Content']}"
  	}
  end

  def process_image(message)
  	{
		toUser: message['FromUserName'],
		fromUser: message['ToUserName'],
		type: 'picurl',
		title: '处理过的照片',
		description: '旋转缩小了一下。',
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
  end
end
