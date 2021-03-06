# encoding: utf-8
require 'workflow'

class Order < ActiveRecord::Base
  attr_accessible :user_id, :receiver_name, :receiver_address, :receiver_code, :receiver_contact, :content
  
  with_options unless: :new? do |o|
    o.validates :receiver_name, :presence => true
    o.validates :receiver_address, :presence => true
    o.validates :receiver_code, :presence => true, :format => { :with => /\A\d{6}\z/,
      :message => "should be 6 digits." }
    o.validates :receiver_contact,:presence => true
  end

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

  require 'prawn'

  def accept
  #   image = images.first
  #   origin_filename = "#{Rails.public_path}#{image.path}"
  #   pdf_filename = "#{origin_filename}.pdf"
  #   front_filename = "#{origin_filename}-front.png"
  #   back_filename = "#{origin_filename}-back.png"
  #   Prawn::Document.generate(pdf_filename, page_size: [454, 332], margin: 0) do
  #     # text 'Hello Dude!'
  #     image front_filename#, position: :left, vposition: :top
  #     image back_filename#, position: :left, vposition: :top
  #   end
  # rescue => ex
  #   puts ex
  #   raise ex
  #   # `open #{filename}`
  end

  def pdf_path
    image = images.first
    "#{image.path}.pdf"
  end

  include Workflow
  workflow do
    state :new do
      event :modify, transitions_to: :modified # 点击预览页面触发这个事件
    end
    state :modified do
      event :modify, transitions_to: :modified
      event :accept, transitions_to: :accepted
    end
    state :accepted do
      event :modify, transitions_to: :modified
    end
    state :rejected
  end
end
