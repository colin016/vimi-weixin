class Image < ActiveRecord::Base
  attr_accessible :index, :order_id, :path
  belongs_to :order

  include ImageWithProcess
end
