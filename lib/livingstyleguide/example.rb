require 'minisyntax'
require 'erb'
require 'hooks'

class LivingStyleGuide::Example
  include Hooks
  include Hooks::InstanceHooks

  define_hooks :filter_example
  @@options = {}

  def initialize(input)
    @source = input
    parse_options
  end

  def render
    %Q(<div class="livingstyleguide--example">\n  #{filtered_example}\n</div>) + "\n" + display_source
  end

  def self.add_option(key, &block)
    @@options[key.to_sym] = block
  end

  private
  def parse_options
    lines = @source.split(/\n/)
    @source = lines.reject do |line|
      if line =~ /^@([a-z-]+)$/
        set_option $1
        true
      end
    end.join("\n")
  end

  private
  def set_option(key)
    instance_eval &@@options[key.to_sym]
  end

  private
  def filtered_example
    html = @source.gsub(/\*\*\*(.+?)\*\*\*/m, '\\1')
    run_hook :filter_example, html
    html
  end

  private
  def display_source
    code = @source.strip
    code = ERB::Util.html_escape(code).gsub(/&quot;/, '"')
    code = ::MiniSyntax.highlight(code, :html)
    code = set_highlights(code)
    %Q(<pre class="livingstyleguide--code-block"><code class="livingstyleguide--code">#{code}</code></pre>)
  end

  private
  def set_highlights(code)
    code = code.gsub(/^\s*\*\*\*\n(.+?)\n\s*\*\*\*(\n|$)/m, %Q(<strong class="livingstyleguide--code-highlight-block">\\1</strong>))
    code = code.gsub(/\*\*\*(.+?)\*\*\*/, %Q(<strong class="livingstyleguide--code-highlight">\\1</strong>))
  end

end
