require 'image+process'

class Image < ActiveRecord::Base
  attr_accessible :index, :order_id, :path
  belongs_to :order

  [:receiver_name, :receiver_address, :receiver_code, :receiver_contact].each do |m|
    delegate m, to: order
  end

  include ImageWithProcess

  def store!(pic_url)
    File.open("#{Rails.public_path}#{self.path}", "wb") do |io|
      io.write(open(pic_url).read())
    end
  end

end
