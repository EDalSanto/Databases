module Nodes
  class HashIndexScan
    def initialize(index_file_path:, keys:)
      @index_file_path = index_file_path
      @keys = keys
      @buffer = []
      @initial = true
    end

    def next
      if @initial
        data = File.open(@index_file_path).read
        @hash_index = Marshal.load(data)
        @initial = false
      elsif @buffer.length == 0 && @keys.length == 0
        # finished
        return nil
      end
      # get next record in index
      if @buffer.length == 0
        # fill buffer with all records for key
        rows = @hash_index[@keys.shift]
        rows.each { |row| @buffer.push(row) }
      end
      @buffer.shift
    end
  end
end


