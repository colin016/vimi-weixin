class String
  def is_number?
    true if Float(self) rescue false
  end
end

class WxTextMessage < WxMessage
  attr_accessor :content
  attr_accessor :msg_id
  attr_accessor :func_flag

  def self.from_content(content)
    m = self.new
    m.content = content
  end

  def template
    'text'
  end

  def to_event
    m_content = self['Content']

    if m_content.is_number?
      return ["数字!", m_content]
    else
      return m_content + '!'
    end  
  end

  def reply(text = nil)
    default_reply = "系统正在升级中，小微会有些胡言乱语，请谅解~\n\n您刚刚说：#{self['Content']}"

    {
      toUser: self['FromUserName'],
      fromUser: self['ToUserName'],
      type: 'text',
      content: text || default_reply
    }
  end

end