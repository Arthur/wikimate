module Wikimate
  class Interpreter
    HEADER = <<EOS
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>TITLE</title>
  </head>
EOS

    attr_reader :path

    def initialize(path, options)
      @path = File.expand_path(path)
      @options = options
    end

    def pages
      return @pages if @pages
      @pages = Dir[path+'/*.md'].map do |md_filename|
        File.basename(md_filename,'.md')
      end
      @pages << 'AllPages'
    end

    def prefix
      @options["prefix"] || ""
    end

    def footer
      %Q(<p class="footer"><a href="#{prefix}/Index.html">Index</a> | <a href="#{prefix}/AllPages.html">AllPages</a></p>)
    end

    def links_in_md
      @links_in_md ||= pages.map do |page|
        "  [#{page}]: #{prefix}/#{page}.html \"#{page}\"\n"
      end.join
    end

    def header
      HEADER
    end

    def edit_links?
      @options["edit_links"]
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
          if edit_links? && line =~ /^#+/
            line += " <a href=\"txmt://open/?url=file://#{md_filename}&line=#{line_number+2}\" class=\"edit\">edit</a>"
            lines[line_number]=line
          end
        end
        markdown = lines.join("\n")+"\n"
      end

      markdown += links_in_md

      html = RDiscount.new(markdown).to_html
      html = "<h1 class=\"title\">#{page}</h1>\n" + html
      header.sub('TITLE', page) + "<body>" + html + footer + "</body>" + '</html>'
    end

  end
end
