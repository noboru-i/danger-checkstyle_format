module Danger
  # Danger plugin for checkstyle formatted xml file.
  #
  # @example Parse the XML file, and let the plugin do your reporting
  #
  #          checkstyle_format.report
  #
  # @see  noboru-i/danger-checkstyle_format
  # @tags lint, reporting
  #
  class DangerCheckstyleFormat < Plugin
    # Base path of `name` attributes in `file` tag.
    # Defaults to nil.
    # @return [String]
    attr_accessor :base_path

    # Report checkstyle warnings
    # @return   [void]
    #
    def report(file, inline_mode = true)
      raise "Please specify file name." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
      errors = parse(file)

      if inline_mode
        send_inline_comment(errors)
      else
        raise "not implemented." # TODO: not implemented.
      end
    end

    CheckstyleError = Struct.new(:file_name, :line, :column, :severity, :message, :source) do
      def self.generate(node, parent_node, base_path)
        CheckstyleError.new(
          parent_node[:name].sub(/^#{base_path}/, ""),
          node[:line].to_i,
          node[:column].nil? ? nil : node[:column].to_i,
          node[:severity],
          node[:message],
          node[:source]
        )
      end
    end

    private

    def parse(file)
      require "ox"

      doc = Ox.parse(File.read(file))
      present_elements = doc.nodes.first.nodes.reject do |test|
        test.nodes.empty?
      end
      base_path_suffix = @base_path.end_with?("/") ? "" : "/"
      base_path = @base_path + base_path_suffix
      elements = present_elements.flat_map do |parent|
        parent.nodes.map do |child|
          CheckstyleError.generate(child, parent, base_path)
        end
      end

      elements
    end

    def send_inline_comment(errors)
      errors.each do |error|
        warn(error.message, file: error.file_name, line: error.line)
      end
    end
  end
end
