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
    recv_m = WxMessage.create(request.body.read)
    user = User.from_message(recv_m)
    m = user.process_message(recv_m)

    @send_message = recv_m.reply(m[:content])
    render @send_message.template
  end

end
