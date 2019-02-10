class FileScan
  def initialize(file_path:)
    @file_path = file_path
    @csv = nil
  end

  def next
    # only process csv for now
    raise if !(File.extname(@file_path) == ".csv")
    # init csv
    @csv = CSV.open(@file_path) if @csv.nil?
    # read one line at time into memory
    record = @csv.readline

    if record
      return record
    else
      return nil
    end
  end
end
