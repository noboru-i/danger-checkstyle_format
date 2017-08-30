require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerCheckstyleFormat do
    it "should be a plugin" do
      expect(Danger::DangerCheckstyleFormat.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @checkstyle_format = @dangerfile.checkstyle_format
      end

      describe ".parse" do
        subject(:errors) { @checkstyle_format.send(:parse, "spec/fixtures/checkstyle.xml") }
        it "have 4 items" do
          expect(errors.size).to be 4
        end

        it "is mapped CheckstyleError about index is 0" do
          expect(errors[0].file_name).to eq("/path/to/XXX.java")
          expect(errors[0].line).to eq(0)
          expect(errors[0].column).to be_nil
          expect(errors[0].severity).to eq("error")
          expect(errors[0].message).to eq("File does not end with a newline.")
          expect(errors[0].source).to eq("com.puppycrawl.tools.checkstyle.checks.NewlineAtEndOfFileCheck")
        end

        it "is mapped CheckstyleError about index is 2" do
          expect(errors[2].file_name).to eq("/path/to/YYY.java")
          expect(errors[2].line).to eq(12)
          expect(errors[2].column).to eq(13)
          expect(errors[2].severity).to eq("error")
          expect(errors[2].message).to eq("Name 'enableOcr' must match pattern '^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$'.")
          expect(errors[2].source).to eq("com.puppycrawl.tools.checkstyle.checks.naming.ConstantNameCheck")
        end
      end
    end
  end
end
