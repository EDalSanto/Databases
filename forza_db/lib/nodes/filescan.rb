module Nodes
  class FileScan
    def initialize(file_path:)
      @file_path = file_path
      @csv = nil
    end

    def next
      # only process csv for now
      raise if !(File.extname(@file_path) == ".csv")
      # init csv
      @csv = CSV.open(@file_path, headers: true) if @csv.nil?
      # read one line at time into memory - could read more to buffer more in memory..
      # TODO: buffer more lines in memory
      # TODO: create a multithreaded control node that fills buffer with multiple threads
      record = @csv.readline
      # return if present, else nil
      record ? record : nil
    end

    def reset
      # csv may not be initialized
      raise if !@csv
      # rewind file pointer
      @csv.rewind
    end
  end
end
