require "../src/crytic/diff"
require "colorize"
require "./spec_helper"

module Crytic
  describe Diff do
    describe "#to_s" do
      it "returns empty string for two empty strings" do
        Diff.unified_diff("", "").should eq ""
      end

      it "doesn't show no changes" do
        Diff.unified_diff("a", "a").should eq ""
      end

      it "shows a header for a single difference" do
        Diff.unified_diff("a", "").lines.first
          .should eq "@@ -1 +0,0 @@"
      end

      it "shows marks the one removed char as deleted in red" do
        Diff.unified_diff("a", "").lines.last
          .should eq "#{"-".colorize.red}#{"a".colorize.red}"
      end

      it "shows marks the one added char as added in green" do
        Diff.unified_diff("", "a").lines.last
          .should eq "#{"+".colorize.green}#{"a".colorize.green}"
      end

      it "shows a few lines around the change" do
        Diff.unified_diff("1\n2\n3\n4\n5\n6\n7\n8\n9", "1\n2\n3\n4\n6\n7\n8\n9")
          .should eq <<-DIFF
          @@ -2,7 +2,6 @@
           2
           3
           4
          #{"-".colorize.red}#{"5".colorize.red}
           6
           7
           8\n
          DIFF
      end

      it "marks multiple changes" do
        Diff.unified_diff("1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n", "1\n2\n3\n4\n6\n7\n8\n9\n10\n11")
          .should eq <<-DIFF
          @@ -2,9 +2,9 @@
           2
           3
           4
          #{"-".colorize.red}#{"5".colorize.red}
           6
           7
           8
           9
           10
          #{"+".colorize.green}#{"11".colorize.green}\n
          DIFF
      end
    end
  end
end
