class Image < ActiveRecord::Base
  attr_accessible :index, :order_id, :path
  belongs_to :order


  def store!(pic_url)
    File.open("#{Rails.public_path}#{self.path}", "wb") do |io|
      io.write(open(pic_url).read())
    end
  end

  include ImageWithProcess
end
