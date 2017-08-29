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
      warn "Test!!" if file.empty?
    end
  end
end
