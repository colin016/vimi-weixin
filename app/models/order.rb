# encoding: utf-8
require 'workflow'

class Order < ActiveRecord::Base
  attr_accessible :user_id, :receiver_name, :receiver_address, :receiver_code, :receiver_contact
  belongs_to :user
  has_many :images

  def self.simple_list(excluded_id = nil)
    order = nil
    if excluded_id
      orders = where("id != #{excluded_id}")
    else
      orders = all
    end

    orders.inject("") { |str, o| str += " #{o.id}: #{o.status}\n" }
  end

  def image_count
    images.count
  end

  def to_s
    " 订单号：#{self.id}\n 收件人：#{self.receiver_name}\n 收件地址：#{self.receiver_address}\n 物流状态：#{self.status}"
  end
  alias description to_s

  include Workflow
  workflow do
    state :new do
      event :accept, transitions_to: :accepted
    end
    state :accepted
    state :rejected
  end
end
