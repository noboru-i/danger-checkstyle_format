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

      describe ".send_inline_comment" do
        it "calls certain argument" do
          errors = [
            CheckstyleError.new("XXX.java", 1, nil, "error", "test message1.", "source"),
            CheckstyleError.new("YYY.java", 2, nil, "error", "test message2.", "source")
          ]
          @checkstyle_format.send(:send_inline_comment, errors)
          expect(@checkstyle_format.status_report[:warnings]).to eq(["test message1.", "test message2."])
          expect(@checkstyle_format.violation_report[:warnings][0]).to eq(Violation.new("test message1.", false, "XXX.java", 1))
          expect(@checkstyle_format.violation_report[:warnings][1]).to eq(Violation.new("test message2.", false, "YYY.java", 2))
        end
      end

      describe ".parse" do
        subject(:errors) do
          @checkstyle_format.base_path = "/path/to"
          @checkstyle_format.send(:parse, File.read("spec/fixtures/checkstyle.xml"))
        end
        it "have 4 items" do
          expect(errors.size).to be 4
        end

        it "is mapped CheckstyleError about index is 0" do
          expect(errors[0].file_name).to eq("XXX.java")
          expect(errors[0].line).to eq(0)
          expect(errors[0].column).to be_nil
          expect(errors[0].severity).to eq("error")
          expect(errors[0].message).to eq("File does not end with a newline.")
          expect(errors[0].source).to eq("com.puppycrawl.tools.checkstyle.checks.NewlineAtEndOfFileCheck")
        end

        it "is mapped CheckstyleError about index is 2" do
          expect(errors[2].file_name).to eq("YYY.java")
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
