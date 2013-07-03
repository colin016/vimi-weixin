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
end
