class WxTextMessage < WxMessage
  attr_accessor :content
  attr_accessor :msg_id
  attr_accessor :func_flag

  def to_event
    m_content = self['Content']

    if m_content.is_number?
      return ["数字!", m_content]
    else
      return m_content + '!'
    end  
  end
end