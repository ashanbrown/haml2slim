module Haml2Slim
  class Converter
    def initialize(haml)
      @slim = ""

      haml.each_line do |line|
        @slim << parse_line(line)
      end
    end

    def to_s
      @slim
    end

    def parse_line(line)
      indent = line[/^[ \t]*/]
      line.strip!

      converted = case line[0]
        when ?%, ?., ?# then parse_tag(line)
        when ?:         then "#{line[1..-1]}:"
        when ?!         then line.sub('!!!', '! doctype')
        when ?-, ?=     then line
        when ?/         then line
        when nil        then ""
        else "| #{line}"
      end

      if converted.chomp!(" |")
        converted.sub!(/^\| /, "")
        converted << " \\"
      end

      "#{indent}#{converted}\n"
    end

    def parse_tag(tag_line)
      tag_line.sub!(/^%/, "")

      if attrs = tag_line.match(/\{(.+)\}/)
        tag   = tag_line.match(/(\w+)\{/)[1]
        attrs = tag_line.match(/\{(.+)\}/)[1]
          .gsub(/:?"?([A-Za-z0-9\-_]+)"? ?=>/, '\1 =>')
          .gsub(/ ?=> ?/, "=")
          .gsub('",', '"')
          # .gsub(/=((?:(?!").)+)/, '=(\1)')

        "#{tag} #{attrs}"
      else
        tag_line
      end
    end
  end
end