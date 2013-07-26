# encoding: utf-8


# include Magick
# class Rails
#   def self.public_path
#     ''
#   end
# end

module ImageWithProcess
  require 'RMagick'
 
  def front
    canvas = Magick::ImageList.new(front_template_path)
    image = Magick::ImageList.new(path)
    image.format = 'jpg'
    canvas.format = 'png'
    canvas.composite!(image.resize_to_fill(815, 562), 65, 65, Magick::AtopCompositeOp)

    canvas
  end

  def back
    @canvas = Magick::ImageList.new(back_template_path)
    draw = Magick::Draw.new
    draw.annotate(@canvas, 0, 0, 73, 100, code || ' ') do
      self.kerning = 20
      self.pointsize = 40
    end

    text = content || "Hello World!"
    # text = "我们很容易被那些纸醉金迷、灯红酒绿，或者类似的我们所从未了解过的世界而吸引，充满好奇和兴趣。但我们也从未对描述这些生活的文字载体产生任何依恋。当我们不再目眩神驰、满纸烟云的时候，那些平淡而缺乏克制的庸俗便会让我们厌倦，最终只是成为我们茶余饭后的消遣。而我们的生活，它依然在脚下。"
    draw = Magick::Draw.new
    
    draw.annotate(@canvas, 0, 0, 80, 170, wrap_text(text, 17)) do 
      self.font = "#{Rails.public_path}/fonts/myfont.ttf"
      # self.font = '/Users/stranbird/dev/vimin-weixin/public/fonts/myfont.ttf'
      self.pointsize = 25
    end

    write_address(name, address)

    @canvas[0]
  end

  def write_address(name, loc)
    name ||= ''
    loc ||= ''
    text = "#{name}(收)\n#{wrap_text(loc, 10)}"

    draw = Magick::Draw.new
    draw.annotate(@canvas, 0, 0, 570, 260, text) do
      self.font = "#{Rails.public_path}/fonts/myfont.ttf"
      # self.font = "/Users/stranbird/dev/vimin-weixin/public/fonts/myfont.ttf"
      self.pointsize = 25
      self.interline_spacing = 23
    end
  end

  def wrap_text(txt, col = 80)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
      "\\1\\3\n") 
  end

  def preview_paths
    [:front, :back].map do |e| 
      path = "#{self.path}-#{e.to_s}.png"
      abs_path = "#{Rails.public_path}/#{path}"
      send(e).write(abs_path)
      path
    end
  end

  # def path
  #   '/Users/stranbird/dev/cat'
  # end

  def name
    self.order.receiver_name
    # "陈乐乐"
  end

  def address
    self.order.receiver_address
    # "上海市闵行区东川路 800号"
  end

  def content
    self.order.content
    # "200240"
  end

  def code
    self.order.receiver_code
    # "200240"
  end

  def back_template_path
    "#{Rails.public_path}/images/postcard-02.png"
    # "/Users/stranbird/Downloads/postcard-02.png"
  end

  def front_template_path
    "#{Rails.public_path}/images/postcard-01.png"
    # "/Users/stranbird/Downloads/postcard-01.png"
  end
end

# include ImageWithProcess

# preview_paths.first { |e| `open #{e}`}
# `open #{preview_paths.first}`