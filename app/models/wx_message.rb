class WxMessage
  attr_accessor :to_user_name
  attr_accessor :from_user_name
  attr_accessor :create_time
  attr_accessor :msg_type

  attr_accessor :status # => :in or :out

  def self.create(xml)
    hash = Hash.from_xml(xml)["xml"]

    case hash["MsgType"]
    when "text"
      WxTextMessage.new(hash)
    when "image" 
      WxImageMessage.new(hash)
    end
  end

  def initialize(hash)
    hash.each_pair do |k, v|
      _k = (k.to_s.underscore + '=')
      self.send(_k, v) if respond_to? _k
    end
  end

  def [](k)
    method_name = k.to_s.underscore
    self.send(method_name) if respond_to? method_name
  end

  def []=(k, v)
    method_name = (k.to_s.underscore + '=')
    self.send(method_name, v) if respond_to? method_name
  end
end