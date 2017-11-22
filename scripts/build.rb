#!/usr/bin/env ruby
require 'date'
require 'json'

class Image
  attr_accessor :raw, :bits, :path, :title, :date, :comments
  def initialize line
    begin
      bits = line.split(/;\|;/)
      @raw = line
      @path = bits[0]
      @title = bits[1]
      @date = Date.parse(bits[2])
      @comments = bits[3]
    rescue
      @title = "unknown_img"
      @path = nil
      @date = Date.parse("12-12-2017")
    end
  end

  def ==(other)
    other.class == self.class && other.path == self.path
  end

  def to_s
    {
      :raw => self.raw,
      :path => self.path,
      :title => self.title,
      :date => self.date,
      :comment => self.comments

    }.to_json
  end
end

def write_page(image, idx)
  template = File.read("template.html")
  template.gsub!(/IMGPATH/,"#{image.path}")
  template.gsub!("TITLE_TEXT", "#{image.title} - #{image.date}")
  if idx == 0
    template.gsub!('<a href = "PREVIOUSPATH">previous </a>|', "")
    template.gsub!('NEXTPATH', "image_#{idx + 1}.html")
  elsif idx == 370
    template.gsub!('|<a href="NEXTPATH"> next</a>', "")
    template.gsub!('PREVIOUSPATH', "image_#{idx - 1}.html")

  else
    template.gsub!('PREVIOUSPATH', "image_#{idx - 1}.html")
    template.gsub!('NEXTPATH', "image_#{idx + 1}.html")
  end
  File.open("image_#{idx}.html", "w") {|f| f.write(template)}
end

## get the list of images from the info file
lines = File.open("info.txt", "r").readlines
lines = lines.reject { |l|  l =~ /(Name|Web|Email|Save\sUser)/  }
images = lines.collect {|l| Image.new(l) }
images = images.reject { |i| i.title == "unknown_img"   }
images = images.uniq {|i| [i.path] }
images = images.sort {|a,b| b.date <=> a.date}

images.each_with_index {|image, idx| write_page(image, idx)}
