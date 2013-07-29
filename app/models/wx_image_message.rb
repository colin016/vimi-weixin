class WxImageMessage < WxMessage
  attr_accessor :pic_url
  attr_accessor :msg_id

  def to_event
    ["照片!", self["PicUrl"]] 
  end
end