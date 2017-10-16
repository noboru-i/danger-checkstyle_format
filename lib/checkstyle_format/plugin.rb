require_relative "checkstyle_error"

module Danger
  # Danger plugin for checkstyle formatted xml file.
  #
  # @example Parse the XML file, and let the plugin do your reporting
  #
  #          checkstyle_format.base_path = Dir.pwd
  #          checkstyle_format.report 'app/build/reports/checkstyle/checkstyle.xml'
  #
  # @example Parse the XML text, and let the plugin do your reporting
  #
  #          checkstyle_format.base_path = Dir.pwd
  #          checkstyle_format.report_by_text '<?xml ...'
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
    #
    # @return   [void]
    def report(file, inline_mode = true)
      raise "Please specify file name." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
      errors = parse(File.read(file))

      send_comment(errors, inline_mode)
    end

    # Report checkstyle warnings by XML text
    #
    # @return   [void]
    def report_by_text(text, inline_mode = true)
      raise "Please specify xml text." if text.empty?
      errors = parse(text)

      send_comment(errors, inline_mode)
    end

    private

    def parse(text)
      require "ox"

      doc = Ox.parse(text)
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

    def send_comment(errors, inline_mode)
      errors.each do |issue|
        file = (inline_mode && issue.file_name != nil && issue.file_name) ? issue.file_name : nil
        line = (inline_mode && issue.line != nil && issue.line > 0) ? issue.line : nil

        if issue.severity == "error"
          fail(issue.message, file: file, line: line)
        elsif issue.severity == "warning"
          warn(issue.message, file: file, line: line)
        else
          message(issue.message, file: file, line: line)
        end
      end
    end

  end
end
