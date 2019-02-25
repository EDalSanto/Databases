require "messages/movie_pb"
require "messages/header_pb"
require "messages/rating_pb"

# Provides APIs for creating and modifying tables
class TableManager
  class TableAlreadyExistsError < StandardError ; end
  DATA_DIR = "/tmp"
  HEADER_SIZE = 16
  PAGE_SIZE = 8_192

  def initialize(name)
    @name = name
    @table_file = nil
    @page_buffer = []
  end

  # creates file for table
  def create
    raise TableAlreadyExistsError if table_exists?
    # create file on disk
    @table_file = File.open("/#{DATA_DIR}/#{@name}.table", "w") do |table_file|
      table_file.write(@init_header.to_proto)
      table_file
    end
    @table_file
  end

  # flushes page buffer to disk
  def flush

  end

  def insert(row)
    # gets current header if exists / space, else creates a new one
    header = Header.new(
      page_size: PAGE_SIZE,
      transaction_id: 0,
      free_space_start: HEADER_SIZE, # right after header
      free_space_end: PAGE_SIZE # very end for init
    )
    @page_buffer.push(@header)

    # get current / last header
    # check if we enough free space for new record in current page in buffer
    # get id from header
    # getermine max size of type
    movie = Movie.new(id: row[:id], name: row[:name]).to_proto
    # add a row at end of free space - size of tuple world byte offset
      # determined in header
    # add a ptr to row's byte offset after last ptr
      # ptr = integer to byte offset
      # location = start of free space found in header
  end

  private

  def find_table_file
    File.open("/#{DATA_DIR}/#{@name}.table", "w+")
  end

  def table_exists?
    File.exists?("/#{DATA_DIR}/#{@name}.table")
  end
end
