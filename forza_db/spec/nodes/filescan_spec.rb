require "spec_helper"
require "csv"
require "nodes/filescan"

describe Nodes::FileScan do
  describe "#next" do
    it "returns the next record from file" do
      # create tmp csv
      headers = "id, name, created_at"
      row1 = "1, foobar, 2019-2-5"
      row2 = "2, bazzz, 2013-2-5"
      rows = [headers, row1, row2]
      tmp_file_path = "/tmp/foobar.csv"
      # write tmp csv
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each do |row|
          csv << row.split(",")
        end
      end
      # create file scan node
      filescan_node = described_class.new(file_path: tmp_file_path)
      # first record present
      record1 = filescan_node.next
      expect(record1).to_not be_nil
      # second record present
      record2 = filescan_node.next
      expect(record2).to_not be_nil
      # always returns nil after
      record3 = filescan_node.next
      expect(record3).to be_nil
      record4 = filescan_node.next
      expect(record4).to be_nil
    end
  end
end
