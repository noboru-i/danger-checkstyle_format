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
    # Report checkstyle warnings
    # @return   [void]
    #
    def report(file)
      raise "Please specify file name." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
      errors = parse(file)

      puts errors.size
    end

    private

    CheckstyleError = Struct.new(:file_name, :line, :column, :severity, :message, :source) do
      def self.generate(node, parent_node)
        CheckstyleError.new(
          parent_node[:name],
          node[:line].to_i,
          node[:column].nil? ? nil : node[:column].to_i,
          node[:severity],
          node[:message],
          node[:source]
        )
      end
    end

    def parse(file)
      require "ox"

      doc = Ox.parse(File.read(file))
      present_elements = doc.nodes.first.nodes.reject do |test|
        test.nodes.empty?
      end
      elements = present_elements.flat_map do |parent|
        parent.nodes.map do |child|
          CheckstyleError.generate(child, parent)
        end
      end

      elements
    end
  end
end
