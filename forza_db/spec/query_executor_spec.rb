require "spec_helper"

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
        ["PROJECTION", ["name"]],
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
      fields = [ "year" ]
      map_func = proc do |row|
        result = {}
        row.each do |field, value|
          result[field] = value if fields.include?(field)
        end
        result
      end
      projection_node = Nodes::Projection.new(map_func: map_func, child: filescan_node)
      sort_node = Nodes::Sort.new(child: projection_node, fields: ["year"])
      query_executor = QueryExecutor.new(root_node: sort_node)
      # setup test
      result_rows = query_executor.execute
      expected = ["1810", "1910", "2010"]
      actual = result_rows.map { |row| row["year"] }
      # run expectation
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
      sort_node = Nodes::Sort.new(child: filescan_node, fields: ["year"], direction: "DESC")
      query_executor = QueryExecutor.new(root_node: sort_node)
      # setup test
      result_rows = query_executor.execute
      expected = ["2010", "1910", "1810"]
      actual = result_rows.map { |row| row["year"] }
      # run expectation
      expect(actual).to eq(expected)
    end

    it "can return only distinct records" do
      [
        ["SORT", ["year" "ASC"]],
        ["DISTINCT", ["id"]],
        ["FILESCAN", ["movies"]]
      ]
      # csv setup
      headers = [ "id", "name", "year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record3 = [ "5001", "Foobar Express", "2010" ]
      record2 = [ "5000", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      tmp_file_path = "/tmp/movies.csv"
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: tmp_file_path)
      hash_child_node = Nodes::Hash.new(child: filescan_node, fields: ["year"])
      distinct_node = Nodes::Distinct.new(hash_child_node: hash_child_node)
      sort_node = Nodes::Sort.new(child: distinct_node, fields: ["year"], direction: "ASC")
      query_executor = QueryExecutor.new(root_node: sort_node)
      result_rows = query_executor.execute
      expected = ["1910", "2010"]
      actual = result_rows.map { |row| row["year"] }
      expect(actual).to eq(expected)
    end

    it "can select the first 2 movies in the movies table sorted by year DESC" do
      [
        ["LIMIT", "2"],
        ["SORT", ["year" "DESC"]],
        ["FILESCAN", ["movies"]]
      ]
      # csv setup
      headers = [ "id", "name", "year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record2 = [ "5000", "Foobar Express", "3010" ]
      record3 = [ "5001", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      tmp_file_path = "/tmp/movies.csv"
      CSV.open(tmp_file_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: tmp_file_path)
      sort_node = Nodes::Sort.new(child: filescan_node, fields: ["year"], direction: "DESC")
      limit_node = Nodes::Limit.new(child: sort_node, limit: 2)
      query_executor = QueryExecutor.new(root_node: limit_node)
      result_rows = query_executor.execute
      expected = ["5000", "4999"]
      actual = result_rows.map { |row| row["id"] }
      expect(actual).to eq(expected)
    end

    it "can join ratings with movie_id 5000 to movies using NestedLoopJoin to get movies ratings" do
      # serialized tree (?correct?)
      [
        ["PROJECTION", ["score"]],
        ["NESTEDLOOPSJOIN", ["ratings.movie_id == movies.id"]],
        [
          [
            ["SELECTION", ["movie_id", "EQUALS", "5000"]],
            ["FILESCAN", ["movies"]],
          ],
          [
            ["FILESCAN", ["ratings"]],
          ],
        ]
      ]
      # csv setup
      # NOTE: db stores files with name of relation prepending column names
      # need distinguish between tables in join
      # movies
      headers = [ "movies.id", "movies.name", "movies.year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record2 = [ "5000", "Foobar Express", "3010" ]
      record3 = [ "5001", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      movies_path = "/tmp/movies.csv"
      CSV.open(movies_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # ratings
      headers = [ "ratings.id", "ratings.score", "ratings.movie_id" ]
      record1 = [ "1", "3", "4999" ]
      record2 = [ "2", "3", "5000" ]
      record3 = [ "3", "4", "5000" ]
      record4 = [ "4", "5", "5001" ]
      rows = [headers, record1, record2, record3, record4]
      ratings_path = "/tmp/ratings.csv"
      CSV.open(ratings_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_ratings_node = Nodes::FileScan.new(file_path: ratings_path)
      filescan_movies_node = Nodes::FileScan.new(file_path: movies_path)
      predicate_func = -> (row) { row["movies.id"] == "5000" }
      selection_movies_node = Nodes::Selection.new(
        predicate_func: predicate_func,
        child: filescan_movies_node
      )
      join_func = -> (movie, rating) { movie["movies.id"] == rating["ratings.movie_id"] }
      nested_loops_join_node = Nodes::NestedLoopsJoin.new(
        children: [selection_movies_node, filescan_ratings_node],
        join_func: join_func
      )
      map_func = -> (row) do
        row.delete_if { |header, value| header != "ratings.score" }
      end # just get score
      projection_node = Nodes::Projection.new(map_func: map_func, child: nested_loops_join_node)
      query_executor = QueryExecutor.new(root_node: projection_node)

      result = query_executor.execute
      expected = ["3", "4"]
      actual = result.map { |row| row["ratings.score"] }
      expect(actual).to eq(expected)
    end

    it "can join ratings to movies using HashJoin" do
      # serialized tree (?correct?)
      [
        ["PROJECTION", ["score"]],
        ["HASHJOIN", ["ratings.movie_id == movies.id"]],
        [
          [
            ["FILESCAN", ["ratings"]],
          ],
          [
            ["HASH",
              ["FILESCAN", ["movies"]], # hash the smaller one so it fits in memory hopefully
            ]
          ],
        ]
      ]
      # csv setup
      # NOTE: db stores files with name of relation prepending column names
      # need distinguish between tables in join
      # movies
      headers = [ "movies.id", "movies.name", "movies.year" ]
      record1 = [ "4999", "Ghostbusters", "2010" ]
      record2 = [ "5000", "Foobar Express", "3010" ]
      record3 = [ "5001", "Cool Runnings", "1910" ]
      rows = [headers, record1, record2, record3]
      movies_path = "/tmp/movies.csv"
      CSV.open(movies_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # ratings
      headers = [ "ratings.id", "ratings.score", "ratings.movie_id" ]
      record1 = [ "1", "3", "4999" ]
      record2 = [ "2", "3", "5000" ]
      record3 = [ "3", "4", "5000" ]
      record4 = [ "4", "5", "5001" ]
      rows = [headers, record1, record2, record3, record4]
      ratings_path = "/tmp/ratings.csv"
      CSV.open(ratings_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_ratings_node = Nodes::FileScan.new(file_path: ratings_path)
      filescan_movies_node = Nodes::FileScan.new(file_path: movies_path)
      # optimizer finds smaller of two relations with something like:
      # %x{wc -l #{movies_path}}.split.first.to_i
      hash_movies_nodes = Nodes::Hash.new(child: filescan_movies_node, fields: ["movies.id"])
      hash_join_node = Nodes::HashJoin.new(
        hash_child_node: hash_movies_nodes,
        other_child_node: filescan_ratings_node,
        join_fields: ["ratings.movie_id"]
      )
      map_func = -> (row) do
        row.delete_if { |header, value| header != "ratings.score" }
      end # just get score
      projection_node = Nodes::Projection.new(map_func: map_func, child: hash_join_node)
      query_executor = QueryExecutor.new(root_node: projection_node)

      result = query_executor.execute
      expected = ["3", "3", "4", "5"]
      actual = result.map { |row| row["ratings.score"] }
      expect(actual).to eq(expected)
    end


    it "can average the rating for movie 5000" do
      [
        ["AVERAGE"],
        ["PROJECTION", ["ratings.score"]],
        ["FILESCAN", ["ratings"]]
      ]
      # csv setup
      headers = [ "ratings.id", "ratings.score", "ratings.movie_id" ]
      record1 = [ "1", "3", "4999" ]
      record2 = [ "2", "3", "5000" ]
      record3 = [ "3", "4", "5000" ]
      record4 = [ "4", "5", "5001" ]
      rows = [headers, record1, record2, record3, record4]
      ratings_path = "/tmp/ratings.csv"
      CSV.open(ratings_path, "w") do |csv|
        rows.each { |row| csv << row }
      end
      # nodes
      filescan_node = Nodes::FileScan.new(file_path: ratings_path)
      fields = [ "ratings.score" ]
      map_func = proc do |row|
        result = {}
        row.each do |field, value|
          result[field] = value if fields.include?(field)
        end
        result
      end
      projection_node = Nodes::Projection.new(map_func: map_func, child: filescan_node)
      average_node = Nodes::Average.new(child: projection_node, field: "ratings.score")
      query_executor = described_class.new(root_node: average_node)
      # run
      result_rows = query_executor.execute
      # assert
      expected = (3 + 3 + 4 + 5) / 4
      actual = result_rows.first
      expect(actual).to eq(expected)
    end
  end
end
