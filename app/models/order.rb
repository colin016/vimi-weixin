# encoding: utf-8
require 'workflow'

class Order < ActiveRecord::Base
  attr_accessible :user_id, :receiver_name, :receiver_address, :receiver_code, :receiver_contact
  belongs_to :user
  has_many :images

  def image_count
    images.count
  end

  def to_s
    "【收件人】#{self.receiver_name}\n【收件人地址】#{self.receiver_address}\n【收件人邮编】#{self.receiver_code}\n【收件人联系方式】#{self.receiver_contact}\n【订单状态】已于#{Time.now - 30.minutes}发件。"
  end
  alias description to_s

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
