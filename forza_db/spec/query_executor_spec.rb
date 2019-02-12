require "spec_helper"
require "query_executor"
require "nodes/projection"
require "nodes/filescan"
require "nodes/selection"
require "nodes/sort"

def create_tmp_csv

end

describe QueryExecutor do
  describe "#execute" do
    it "can return the name column for the movie row with id 5000" do
      # serialized form
      [
        ["PROJECTION", ["name"]],
        ["SELECTION", ["id", "EQUALS", "5000"]],
        ["FILESCAN", ["movies"]]
      ]
      # csv setup
      headers = ["id", "name"]
      record1 = [ "4999", "Ghostbusters" ]
      record2 = [ "5000", "Cool Runnings" ]
      rows = [headers, record1, record2]
      tmp_file_path = "/tmp/movies.csv"
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: tmp_file_path)
      predicate_func = proc { |row| row["id"] == "5000"}
      selection_node = Nodes::Selection.new(predicate_func: predicate_func, child: filescan_node)
      fields = [ "name" ]
      map_func = proc do |row|
        result = {}
        row.each do |field, value|
          result[field] = value if fields.include?(field)
        end
        result
      end
      projection_node = Nodes::Projection.new(map_func: map_func, child: selection_node)
      query_executor = described_class.new(root_node: projection_node)
      # run
      result_rows = query_executor.execute
      # assert
      expect(result_rows.length).to eq(1)
      expect(result_rows.map(&:keys).flatten.uniq).to eq(["name"])
      expect(result_rows[0]["name"]).to eq("Cool Runnings")
    end

    it "can sorts rows by specified columns ASC" do
      [
        ["SORT", ["year"]],
        ["FILESCAN", ["movies"]]
      ]
      # csv setup
      headers = [ "id", "name", "year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record3 = [ "5001", "Foobar Express", "1810" ]
      record2 = [ "5000", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      tmp_file_path = "/tmp/movies.csv"
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: tmp_file_path)
      sort_node = Nodes::Sort.new(child: filescan_node, keys: ["year"])
      query_executor = QueryExecutor.new(root_node: sort_node)
      result_rows = query_executor.execute
      expected = ["1810", "1910", "2010"]
      actual = result_rows.map { |row| row["year"] }
      expect(actual).to eq(expected)
    end

    it "can sorts rows by specified columns DESC" do
      [
        ["SORT", ["year" "DESC"]],
        ["FILESCAN", ["movies"]]
      ]
      # csv setup
      headers = [ "id", "name", "year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record3 = [ "5001", "Foobar Express", "1810" ]
      record2 = [ "5000", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      tmp_file_path = "/tmp/movies.csv"
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: tmp_file_path)
      sort_node = Nodes::Sort.new(child: filescan_node, keys: ["year"], direction: "DESC")
      query_executor = QueryExecutor.new(root_node: sort_node)
      result_rows = query_executor.execute
      expected = ["2010", "1910", "1810"]
      actual = result_rows.map { |row| row["year"] }
      expect(actual).to eq(expected)
    end

    it "can return only distinct records" do
      [
        ["DISTINCT", ["id"]],
        ["FILESCAN", ["movies"]]
      ]
    end

    it "can select the first 100 movies in the movies table" do
      [
        ["LIMIT", "100"],
        ["FILESCAN", ["movies"]]
      ]
    end

    it "can average the rating for movie 5000" do
      [
        ["AVERAGE"],
        ["PROJECTION", ["rating"]],
        ["SELECTION", ["movie_id", "EQUALS", "5000"]],
        ["FILESCAN", ["ratings"]]
      ]
    end

    it "can determine how many movies in total have been rated" do
      [
        ["SUM"],
        ["FILESCAN", ["ratings"]]
      ]
    end

    it "can select the movie id and average rating for the top 10 rated movies" do

    end
  end
end
