module LivingStyleGuide

  class Engine
    attr_accessor :markdown, :files, :options

    @@default_options = {
      default_language: 'example',
      title: 'Living Style Guide',
      header: '<h1 class="livingstyleguide--page-title">Living Style Guide</h1>',
      footer: '<div class="livingstyleguide--footer"><a class="livingstyleguide--logo" href="http://livingstyleguide.org">Made with the LivingStyleGuide gem.</a></div>'
    }

    def self.default_options
      @@default_options
    end

    def initialize(source, options, sass_options)
      @source = source
      @options = @@default_options.merge(options)
      @sass_options = sass_options
      @markdown = ''
      @files = []
    end

    def render
      data = TemplateData.new(self)
      template = File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'layouts', 'default.html.erb'))
      ERB.new(template).result(data.get_binding)
    end

    def css
      sass_engine.render
    end

    def html
      renderer = RedcarpetHTML.new(@options)
      redcarpet = ::Redcarpet::Markdown.new(renderer, REDCARPET_RENDER_OPTIONS)
      redcarpet.render(markdown)
    end

    private
    def sass_engine
      return @sass_engine if @sass_engine
      sass_options = @sass_options.clone
      sass_options[:living_style_guide] = self
      @sass_engine = ::Sass::Engine.new(@source, sass_options)
    end

  end

  class TemplateData
    include ERB::Util

    def initialize(engine)
      @engine = engine
    end

    def get_binding
      binding
    end

    def title
      @engine.options[:title]
    end

    def css
      @engine.css
    end

    def html
      @engine.html
    end

    def head
      (@engine.options[:javascript_before] || []).map do |src|
        %Q(<script src="#{src}"></script>)
      end.join("\n")
    end

    def header
      contents = [@engine.options[:header]]
      contents.join("\n")
    end

    def footer
      contents = [@engine.options[:footer]]
      contents << (@engine.options[:javascript_after] || []).map do |src|
        %Q(<script src="#{src}"></script>)
      end
      contents.join("\n")
    end

  end

end

