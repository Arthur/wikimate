module Wikimate
  class Interpreter
    HEADER = <<EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" type="text/css" media="screen" href="/wikimate.css" />
    <script type="text/javascript" src="/wikimate.js"></script>
    <title>TITLE</title>
  </head>
EOS

FOOTER = <<EOS
  <p class="footer"><a href="/Index.html">Index</a> | <a href="/AllPages.html">AllPages</a></p>
EOS

    attr_reader :path, :pages

    def initialize(path)
      @path = File.expand_path(path)
      get_pages
    end

    def get_pages
      @pages = Dir[path+'/*.md'].map do |md_filename|
        File.basename(md_filename,'.md')
      end
      @pages << 'AllPages'
    end

    def links_in_md
      @links_in_md ||= pages.map do |page|
        "  [#{page}]: #{page}.html \"#{page}\"\n"
      end.join
    end

    def header
      HEADER
    end

    def html_for_page(page, options = {})
      if page == "AllPages"
        markdown = (pages - ["AllPages"]).sort.map do |p|
          " * [#{p}][#{p}]\n"
        end.join
      else
        md_filename = "#{path}/#{page}.md"
        markdown = File.open(md_filename).read
      end

      # set wiki link in md format
      pages.each do |p|
        markdown.gsub!(/([^\[])#{p}\b/,"\\1[#{p}][#{p}]")
      end
      markdown.gsub!(/\[+/,'[')
      markdown.gsub!(/\]+/,']')

      # set edit link
      if md_filename
        paragraphs = []
        lines = markdown.split("\n")
        lines.each_with_index do |line, line_number|
          if line =~ /^#+/
            # line += "\n[edit](txmt://open/?url=file://#{md_filename}&line=#{line_number+2})"
            line += " <a href=\"txmt://open/?url=file://#{md_filename}&line=#{line_number+2}\" class=\"edit\">edit</a>"
            lines[line_number]=line
          end
        end
        markdown = lines.join("\n")+"\n"
      end

      markdown += links_in_md

      html = RDiscount.new(markdown).to_html
      html = "<h1 class=\"title\">#{page}</h1>\n" + html
      header.sub('TITLE', page) + "<body>" + html + FOOTER + "</body>" + '</html>'
    end

  end
end
