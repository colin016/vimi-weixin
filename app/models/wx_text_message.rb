class WxTextMessage < WxMessage
  attr_accessor :content
  attr_accessor :msg_id
  attr_accessor :func_flag

  attr_accessor :status # => :in or :out
end