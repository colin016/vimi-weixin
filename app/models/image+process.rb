# encoding: utf-8


# include Magick

module ImageWithProcess
  require 'RMagick'

  def front
    canvas = Magick::Image.new(453, 332) { self.background_color = '#fefefe' }
    image = Magick::ImageList.new("#{Rails.public_path}#{self.path}")
    canvas.composite!(image.crop(0, 0, 391, 272), 30, 31, Magick::AtopCompositeOp)

    canvas
  end

  def back
    @canvas = Magick::ImageList.new("/Users/stranbird/Downloads/postcard无文字.png")
    draw = Magick::Draw.new
    draw.annotate(@canvas, 0, 0, 36, 48, "200240") do
      self.kerning = 10
      self.pointsize = 18
    end

    text = "我们很容易被那些纸醉金迷、灯红酒绿，或者类似的我们所从未了解过的世界而吸引，充满好奇和兴趣。但我们也从未对描述这些生活的文字载体产生任何依恋。当我们不再目眩神驰、满纸烟云的时候，那些平淡而缺乏克制的庸俗便会让我们厌倦，最终只是成为我们茶余饭后的消遣。而我们的生活，它依然在脚下。"
    draw = Magick::Draw.new
    
    draw.annotate(@canvas, 0, 0, 40, 84, wrap_text(text, 13)) do 
      self.font = "/Users/stranbird/Library/Fonts/myfont.ttf"
      self.pointsize = 16
    end

    address("陈乐乐", "上海市闵行区东川路 800号上海交通大学 F090309070")

    @canvas[0]
  end

  def address(name, loc)
    text = "#{name}(收)\n#{wrap_text(loc, 10)}"

    draw = Magick::Draw.new
    draw.annotate(@canvas, 0, 0, 276, 120, text) do
      self.font = "/Users/stranbird/Library/Fonts/myfont.ttf"
      self.pointsize = 15
      self.interline_spacing = 12
    end
  end

  def wrap_text(txt, col = 80)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
      "\\1\\3\n") 
  end

  def preview_paths
    [:front, :back].map do |e| 
      path = "#{self.path}-#{e.to_s}"
      send(e).write(path)
      path
    end
  end
end