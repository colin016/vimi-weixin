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
  	@send_message = {
		toUser: @receive_message['FromUserName'],
		fromUser: @receive_message['ToUserName'],
		type: 'text',
		content: @receive_message['Content']
  	}
  	puts @receive_message
  	puts @send_message

  	render :talk
  end
end
