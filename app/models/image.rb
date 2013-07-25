require 'image+process'

class Image < ActiveRecord::Base
  attr_accessible :index, :order_id, :path
  belongs_to :order

  include ImageWithProcess

  def store!(pic_url)
    File.open("#{Rails.public_path}#{self.path}", "wb") do |io|
      io.write(open(pic_url).read())
    end
  end

end
