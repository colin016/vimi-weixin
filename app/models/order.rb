# encoding: utf-8
require 'workflow'

class Order < ActiveRecord::Base
  attr_accessible :user_id

  def state_in_words
  	case current_state.to_sym
  	when :new
  	when :asking_name
	  	"请问您的姓名："
  	when :asking_address
	  	"请问您的地址："
  	when :asking_contact
	  	"请问您的联系方式："
	  when :submiting
	  	"您的姓名是：\n地址：\n联系方式：\n"
	  when :accepted
	  	"下单成功！"
	  else
  	end
  end

  def reject
  	"已经取消订单。"
  end

  include Workflow
  workflow do
    state :new do
      event :proceed, :transitions_to => :asking_name
    end
    state :asking_name do
      event :proceed, :transitions_to => :asking_address
      event :reinput, :transitions_to => :asking_name
    end
    state :asking_address do
      event :proceed, :transitions_to => :asking_contact
      event :reinput, :transitions_to => :asking_address
    end
    state :asking_contact do
    	event :proceed, :transitions_to => :submiting
    	event :reinput, :transitions_to => :asking_contact
    end
    state :submiting do
    	event :proceed, :transitions_to => :accepted
    	event :reinput, :transitions_to => :rejected
    end
    state :accepted
    state :rejected
  end
end
