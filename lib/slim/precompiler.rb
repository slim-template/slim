# encoding: utf-8

module Slim
  module Precompiler
    
    # All HTML 5 compatible tags
    HTML = %w(abbr address area article aside audio base bdo blockquote body br button canvas caption cite code colgroup col command datalist dd del details dfn div dl dt embed em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 header head hgroup hr html iframe img input ins keygen kbd label legend link li map mark menu meta meter nav noscript object ol optgroup option output param pre progress q rp rt ruby samp script section select small source span strong style sub summary sup table tbody td textarea tfoot thead th time title tr ul var video a b i p)

    AUTOCLOSED = %w(meta img link br hr input area param col base)

    HTML_REGEX = /^(\s+)?(#{HTML.join('|')})(\s+?\w*=".+")?(\s*?=.*)?(.*)?/
    CODE_REGEX = /^(\s+)?-/

    def precompile
      @precompiled = ""

      last_indent = 0; tags = []

      @template.each_line do |line|
        if line =~ HTML_REGEX
          indent = $1.to_s.length; tag = $2; attributes = $3; ruby = $4; text = $5;

          attributes.gsub!('"','\"') if attributes

          unless indent > last_indent
            pop_tag_indent = indent + 1
            until indent >= pop_tag_indent do
              pop_tag, pop_tag_indent = tags.pop
              @precompiled << "\"</#{pop_tag}>\"" if pop_tag
            end
          end

          last_indent = indent

          @precompiled << "\"<#{tag}#{attributes || ''}\""

          if AUTOCLOSED.include?(tag)
            tags << [nil, indent]
            @precompiled << "\"/>\""
          else
            tags << [tag, indent]
            @precompiled << "\">\""
          end

          if text
            @precompiled << "\"#{text.strip}\""
          end
        elsif line =~ CODE_REGEX
          @precompiled << line
        else 
          @precompiled << "\"#{line}\""
        end
      end # template iterator

      tags.reverse_each do |t|
        @precompiled << "\"</#{t[0]}>\""
      end
    end
  end
end
