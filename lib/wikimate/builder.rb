module Wikimate
  class Builder
    def initialize(root,output_dir, options = {})
      @root = root
      @output_dir = output_dir
      @options = options
    end

    def run
      FileUtils.mkdir_p @output_dir
      interpreter = Interpreter.new(@root, @options)
      interpreter.pages.each do |page|
        File.open(File.join(@output_dir, page+".html"),"w") do |file|
          file.write interpreter.html_for_page(page)
        end
      end
    end

  end
end
