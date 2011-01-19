#!/usr/bin/ruby

require 'open-uri'

name = ''

def rewrite_image(html, name)
  ret = ''
  html.each { |line|
    line.gsub!(/<(\S+\s+\S+)=\"(http\:\/\/playlog\.jp)*\/_images\/blog\/(\S\/\S\/)*\S+\/(m_)*(\d+\.jpg)/) {
      open("http://playlog.jp/_images/blog/#{$3}#{name}/#{$4}#{$5}") { |img|
        open("#{name}/#{$4}#{$5}", "w") { |f|
            f.write(img.read)
        }
      }
      "<#{$1}=\"#{$4}#{$5}"
    }
    ret << line
  }
  return ret
end

def get_month(name, archive)
  html = ''
  open("http://playlog.jp/#{name}/#{archive}") { |http|
    html = http.readlines
  }
  fn = File.basename(archive)
  open("#{name}/#{fn}.html", "w") { |io|
    io.print rewrite_image(html, name)
  }
end

name = ARGV[0]
html = ''
Dir.mkdir(name) if (! File.directory?(name))

open("http://playlog.jp/#{name}/blog") { |http|
  html = http.readlines
}
html.each { |line|
  line.scan(/blog\/archive\/\d{6}/) { |archive|
    get_month(name, archive)
  }
}
