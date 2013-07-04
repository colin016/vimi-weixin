require 'workflow'

class User < ActiveRecord::Base
  attr_accessible :openid
  after_initialize :default_values

  include Workflow
  workflow do
    state :normal do
      event :order, transitions_to: :ordering
      event :query, transitions_to: :querying
      event :exit, transitions_to: :normal
    end

    state :ordering do
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
      "1. 输入【查订单】查询订单\n2. 发送照片创建明信片"
    end
  end

private
  def default_values
    self.workflow_state ||= :normal
  end
end

