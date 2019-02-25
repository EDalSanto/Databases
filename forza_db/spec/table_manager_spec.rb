require "spec_helper"

describe TableManager do
  before do
    new_table_name = "movies"
    table_manager = TableManager.new(new_table_name)
    @new_table_file = table_manager.create
  end

  after do
    File.delete(@new_table_file)
  end

  describe "#create" do
    it "creates a file for table" do
      expect(@new_table_file).to be_a(File)
    end

    it "encodes a header" do
      f = File.open(@new_table_file)
      header_bytes = f.read(TableManager::HEADER_SIZE)
      header = Header.decode(header_bytes)
      expect(header.free_space_start).to eq(TableManager::HEADER_SIZE)
    end
  end

  describe "#insert" do
    it "stores records in the buffer of in-memory pages" do
      movies = [
        { name: "FooBar Returns" },
        { name: "Baz and Foo" },
        { id: 3, name: "Hey there" }
      ]

      # add records
      movies.each { |movie| table_manager.insert(movie) }

      # count records from buffer
      records_count = table_manager.buffer.reduce(0) do |count, page|
        count += page.header.records_count ; count
      end
    end
  end

  describe "#flush" do
    it "flushes the current buffer of pages to the database file" do
      movies = [
        { name: "FooBar Returns" },
        { name: "Baz and Foo" },
        { id: 3, name: "Hey there" }
      ]

      # add records
      movies.each { |movie| table_manager.insert(movie) }

      # expect buffer to have page with records
      buffer = table_manager.page_buffer
      # expect file to have no records
      table_manager.flush
      # expect buffer to be empty
      # expect file to have records
    end
  end
end
