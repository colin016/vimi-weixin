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

  ImageNum = 1

  attr_accessor :res

  include Workflow
  workflow do
    state :normal do
      event "明信片", transitions_to: :ordering
      event :q, transitions_to: :normal
      event "找客服", transitions_to: :normal

      event "数字", transitions_to: :normal
      event "查订单", transitions_to: :normal
    end

    state :ordering do
      event "帮助", transitions_to: :ordering
      event "照片", transitions_to: :ordering
      event "下单", transitions_to: :normal
      event :q, transitions_to: :normal

      event "查订单", transitions_to: :ordering
      event "数字", transitions_to: :ordering
    end

    # state :querying do
    #   event :q, transitions_to: :normal
    #   event "数字", transitions_to: :normal
    # end
  end

  def q
    self.latest_order.destroy if self.ordering? && self.latest_order && self.latest_order.current_state < :accepted

    content = ''
    if current_state == :normal
    else
      content ="您已经退出了明信片制作~~想要重新制作，请回复【明信片】~"
    end

    self.res = {
      type: "text",
      content: content
    }
  end

  def 明信片
    content = "【明信片介绍】\n\n请选择您希望打印的照片直接发给小印~\n\n如果有问题请回复【帮助】\n\n制作明信片过程中您如果想要退出，可以随时回复【q】哦~~"
    self.res = {
      type: "text",
      content: content
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
      self.q!
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
    o.accept!
    self.res = {
      type: "text",
      content: "点击以下链接，进入帮助页面【网页链接】。\n如果您还有其他问题，请回复【找客服】。\n如果您准备好了，现在就可以继续发照片给我们了哦（您已发#{o.images.count}张照片）~~"
    }
  end

  def 找客服
    # TODO
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
    o = self.latest_order

    im = o.images.create({path: "/images/#{SecureRandom::uuid}"})
    im.store!(pic_url)

    o.save

    if o.images.count < ImageNum then
      raise "SHOULDN'T BE HERE"
    else
      self.res = {
        type: "text",
        content: "收到您的照片啦~ 请点击以下链接填写您的邮寄信息。\n #{edit_order_url(o, host: host)}\n\n 如果您觉得没问题，就请回复【下单】吧~~"
      }
    end
  end

  def 下单
    o = self.latest_order
    o.accept!

    self.res = {
      type: "text",
      content: "亲~ 您的订单已经提交，订单号是#{o.id}。微米印打印完您的明信片就会按照您指示的时间寄出滴~~"
    }
  rescue Workflow::NoTransitionAllowed => ex
    self.res = {
      type: "text",
      content: "请补全您的信息，小印才能寄出哦"
    }
    raise ex
  end

  def latest_order
    if (o = self.orders.last) && (not o.accepted?)
      return o
    else
      return self.orders.create
    end
  end

public

  def process_message(m)
    event = message_to_event(m)
    p event
    self.send(*event)
  rescue NoMethodError => ex
    p ex
    self.q!
  ensure
    return self.res
  end

  def message_to_event(m)
    case m["MsgType"]
    when 'text'
      m_content = m['Content']

      if m_content.is_number?
        return ["数字!", m_content]
      else
        return "#{m_content}!"
      end
    when 'image'
      return ["照片!", m["PicUrl"]]
    else
    end
  end

private
  def host
    '106.186.29.15'
  end

  def default_values
    self.workflow_state ||= :normal
  end
end