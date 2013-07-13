# encoding: utf-8

require 'workflow'

class String
  def is_number?
    p "1"*20
    true if Float(self) rescue false
  end
end


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

  def 照片
    
  end

  def 下单
    self.res = {
      type: "text",
      content: "感谢您下单！请在以下链接中输入您的邮寄信息。\n\n 【网页链接】"
    }
  end

  def 确认
    self.res = {
      type: "text",
      content: "亲~ 您的订单已经提交，订单号是#{Order.new.id}。请尽快支付，以便我们为您制作和邮寄~~\n支付地址：【支付地址链接】\n\n如果支付期间遇到问题，请回复【找客服】。"
    }
  end

  def 数字(num)
    puts "In #{__method__}"
  end

  include Workflow
  workflow do
    state :normal do
      event "查订单", transitions_to: :querying
      event "照片卡", transitions_to: :ordering
      event :exit, transitions_to: :normal
      event "找客服", transitions_to: :normal
    end

    state :ordering do
      event "帮助", transitions_to: :ordering
      event "照片", transitions_to: :ordering
      event "下单", transitions_to: :submitting
      event :exit, transitions_to: :normal
    end

    state :querying do
      event :exit, transitions_to: :normal
    end

    state :submitting do
      event "确认", transitions_to: :normal
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
    event = message_to_event(m)
    self.send(*event)

    return res
  rescue => ex
    p ex
    self.exit!
  end

  def message_to_event(m)
    if m["MsgType"] == 'text'
      m_content = m['Content']

      if m_content.is_number?
        return ["数字!", m_content]
      else
        return "#{m_content}!"
      end

    elsif m["MsgType"] == 'image'
      return "照片!"
    end
  end  

private
  def default_values
    self.workflow_state ||= :normal
  end
end