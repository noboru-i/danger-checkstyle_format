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
