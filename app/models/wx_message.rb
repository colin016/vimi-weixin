class WxMessage
  attr_accessor :to_user_name
  attr_accessor :from_user_name
  attr_accessor :create_time
  attr_accessor :msg_type

  attr_accessor :status # => :in or :out

  def initialize(xml)
    @hash = Hash.from_xml(xml)["xml"]
    @hash.each_pair do |k, v|
      _k = (k.to_s.underscore + '=')
      self.send(_k, v) if respond_to? _k
    end
  end

  def [](key)
    method_name = key.to_s.underscore
    self.send(method_name) if respond_to? method_name
  end
end