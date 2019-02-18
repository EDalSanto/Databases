class HashIndexBuilder
  def initialize(table_file_path:, key:)
    @table_file_path = table_file_path
    @key = key
  end

  def build_index!
    # build in-memory hash index
    index = {}
    # convert to reference to somewhere in CSV
    # TODO: convert from CSV to binary for tables too
    CSV.foreach(@table_file_path, headers: true) do |row|
      lookup_value = row[@key]
      existing_records = index[lookup_value]
      if existing_records
        existing_records.push(row)
      else
        index[lookup_value] = [ row ]
      end
    end
    # write hash index to disk as binary in file
    ratings_name_index = File.new("/tmp/ratings_movie_id_hash_index", "w")
    serialized_binary = Marshal.dump(index)
    ratings_name_index.write(serialized_binary)
    ratings_name_index.close
  end
end
