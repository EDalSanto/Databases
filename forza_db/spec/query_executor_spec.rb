require "spec_helper"
require "query_executor"
require "nodes/projection"
require "nodes/filescan"
require "nodes/selection"

def create_tmp_csv

end

describe QueryExecutor do
  describe "#execute" do
    it "returns the name column for the movie row with id 5000" do
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

    it "returns the average rating for movie 5000" do
      [
        ["AVERAGE"],
        ["PROJECTION", ["rating"]],
        ["SELECTION", ["movie_id", "EQUALS", "5000"]],
        ["FILESCAN", ["ratings"]]
      ]
    end

    it "selects the first 100 movies in the movies table" do

    end

    it "determines how many movies in total have been rated" do

    end

    it "selects the movie id and average rating for the top 10 rated movies" do

    end
  end
end
