# encoding: utf-8
require 'workflow'

class Order < ActiveRecord::Base
  attr_accessible :user_id, :receiver_name, :receiver_address, :receiver_code, :receiver_contact


  def state_in_words
  	case current_state.to_sym
  	when :new
  	when :asking_name
	  	"我们可以为你将这张照片制作成精美的明信片，三天之后寄给您的朋友。只需要回答下边几个问题就好~\n\n1. 收件人姓名是？"
  	when :asking_address
	  	"2. #{self.receiver_name}的地址是？"
    when :asking_code
	  	"3. 地址记下啦，TA的邮编是？"
    when :asking_contact
	  	"4. 邮编收到 ，TA的联系方式是？"
    # when :submiting
    #   "订单收到，正在生成明信片预览... "
	  when :accepted
	  	"下单成功！"
	  else
  	end
  end

  def proceed(info = "")
    case current_state.to_sym
    when :new
    when :asking_name
      self.update_attribute(:receiver_name, info)
    when :asking_address
      self.update_attribute(:receiver_address, info)
    when :asking_code
      self.update_attribute(:receiver_code, info)
    when :asking_contact
      self.update_attribute(:receiver_contact, info)
    end
  end

  def to_s
    "【收件人】#{self.receiver_name}\n【收件人地址】#{self.receiver_address}\n【收件人邮编】#{self.receiver_code}\n【收件人联系方式】#{self.receiver_contact}\n【订单状态】已于#{Time.now - 30.minutes}发件。"
  end

  include Workflow
  workflow do
    state :new do
      event :proceed, :transitions_to => :asking_name
    end
    state :asking_name do
      event :proceed, :transitions_to => :asking_address
    end
    state :asking_address do
      event :proceed, :transitions_to => :asking_code
    end
    state :asking_code do
    	event :proceed, :transitions_to => :asking_contact
    end
    state :asking_contact do
      event :proceed, :transitions_to => :submiting
    end
    state :submiting do
    	event :proceed, :transitions_to => :accepted
    end
    state :accepted
    state :rejected
  end
end
