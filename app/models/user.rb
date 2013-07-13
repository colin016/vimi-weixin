# encoding: utf-8

require 'workflow'

class User < ActiveRecord::Base
  attr_accessible :openid
  after_initialize :default_values

  attr_accessor :res

  def 照片卡
    puts "In #{__method__}"
  end

  def 查订单
    puts "In #{__method__}"
  end

  def 帮助
    self.res = {
      type: "text",
      content: "点击以下链接，进入帮助页面【网页链接】。\n如果您还有其他问题，请回复【找客服】。\n如果您准备好了，现在就可以继续发照片给我们了哦（您已发#{7}张照片）~~"
    }
  end

  def 找客服
    # TODO
  end

  include Workflow
  workflow do
    state :normal do
      event "查订单", transitions_to: :ordering
      event "照片卡", transitions_to: :querying
      event :exit, transitions_to: :normal
    end

    state :ordering do
      event "帮助", transitions_to: :ordering
      event :exit, transitions_to: :normal
    end

    state :querying do
      event :exit, transitions_to: :normal
    end
  end

public
  def state_in_words
    case self.workflow_state.to_sym
    when :normal
      "（实验功能！即将上线~ 上线之前所有订单无效。）\n1. 输入【查订单】查询订单\n2. 发送照片创建明信片"
    end
  end

  def process_message(m)
    m_content = m['Content']
    event = "#{m_content}!"
    self.send(event)

    return res
  rescue => ex
    puts ex
    self.exit!
  end

private
  def default_values
    self.workflow_state ||= :normal
  end
end

