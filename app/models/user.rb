# encoding: utf-8

require 'workflow'
require 'open-uri'

class String
  def is_number?
    true if Float(self) rescue false
  end
end


class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :openid
  after_initialize :default_values
  has_many :orders

  attr_accessor :res

  def 照片卡
    self.res = {
      type: "text",
      content: "请选择您希望打印的12张照片发给我们。如果发照片期间您有问题，请回复【帮助】。"
    }
  end

  def 查订单
    orders = self.orders
    order_num = orders.count
    latest_order = orders.last

    if order_num == 0
      self.res = {
        type: "text",
        content: "暂时还没有您的订单。"
      }
      self.exit!
    else
      self.res = {
        type: "text",
        content: "以下是您最新一笔订单的信息与状态：\n#{latest_order.description}"
      }
    end

    if order_num > 1 
      self.res[:content] += "\n\n您还有#{order_num - 1}份历史订单，分别是：\n#{orders.simple_list(latest_order.id)}\n输入订单号查询这些订单。"
    end
  end

  def 帮助
    o = self.latest_order
    self.res = {
      type: "text",
      content: "点击以下链接，进入帮助页面【网页链接】。\n如果您还有其他问题，请回复【找客服】。\n如果您准备好了，现在就可以继续发照片给我们了哦（您已发#{o.images.count}张照片）~~"
    }
  end

  def 找客服
    # TODO
  end

  def 下单
    o = self.latest_order
    self.res = {
      type: "text",
      content: "感谢您下单！请在以下链接中输入您的邮寄信息。\n\n #{edit_order_url(o, :host => host)}"
    }
  end

  def 确认
    o = self.latest_order
    o.accept!

    self.res = {
      type: "text",
      content: "亲~ 您的订单已经提交，订单号是#{o.id}。请尽快支付，以便我们为您制作和邮寄~~\n支付地址：【支付地址链接】\n\n如果支付期间遇到问题，请回复【找客服】。"
    }
  end

  def 数字(num)
    o = self.orders.find(num)

    self.res = {
      type: "text",
      content: "以下是您查询的订单的信息与状态：\n#{o.description}"
    }
  rescue ActiveRecord::RecordNotFound
    self.res = {
      type: "text",
      content: "对不起，没有与您查询相符的订单，请重新输入。\n\n您有#{orders.count}份历史订单，分别是：\n#{orders.simple_list}输入订单号查询这些订单。"
    }
  ensure
    puts "In #{__method__}(#{num})"
  end

  def 照片(pic_url)
    puts "1"*20
    o = self.latest_order
    im = o.images.create({path: "/images/#{SecureRandom::uuid}"})
    File.open("#{Rails.public_path}#{im.path}", "wb") do |io|
      io.write(open(pic_url).read())
    end
    o.save

    p o.images
    if o.images.count < 3 then
      self.res = {
        type: "text",
        content: "收到#{o.images.count}张照片。"
      }
    else
      puts "2"*20

      self.res = {
        type: "text",
        content: "亲~您已发了3张照片，请点击一下链接查看您的照片。\n #{edit_order_url(o, host: host)}\n\n 如果您觉得没问题，就请回复【下单】吧~~"  
      }
    end
  end

  def 下单
    puts "3"*20
    o = self.latest_order
    self.res = {
      type: "text",
      content: "以下是订单信息：\n#{o.description}\n\n如果信息有误，请点击一下链接修改：#{edit_order_url(o, host: host)}\n确认信息请回复【确认】~~"
    } 
  end

  def exit
    self.res = {
      type: "text",
      content: "（实验功能！即将上线~ 上线之前所有订单无效。）\n1. 输入【查订单】查询订单。\n2. 输入【照片卡】创建照片卡。"
    }
    
  end

  def latest_order
    if (o = self.orders.last) && (not o.accepted?)
      return o
    else
      return self.orders.create
    end
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
      event "数字", transitions_to: :normal
    end

    state :submitting do
      event "确认", transitions_to: :normal
    end
  end

public

  def process_message(m)
    event = message_to_event(m)
    self.send(*event)

    return res
  rescue NoMethodError, Workflow::NoTransitionAllowed => ex
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
      return ["照片!", m["PicUrl"]]
    end
  end

  def send_message(text)
    
  end

private
  def host
    'weixin-forward.vida.fm'
  end

  def default_values
    self.workflow_state ||= :normal
  end
end