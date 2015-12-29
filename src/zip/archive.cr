require "./constants"

module Zip
  # Main zip archive class.  Use the `Archive.create` and `Archive.open`
  # class methods to create a new archive or open an existing archive,
  # respectively.
  #
  # ### Examples
  #
  #     # create a new archive named foo.zip and populate it
  #     Zip::Archive.create("foo.zip") do |zip|
  #       # add file "/path/to/foo.txt" to archive as "bar.txt"
  #       zip.add_file("bar.txt", "/path/to/foo.txt")
  #
  #       # add file "baz.txt" with contents "hello world!"
  #       zip.add("baz.txt", "hello world!")
  #     end
  #
  #     # open existing archive "foo.zip" and extract "bar.txt" from it
  #     Zip::Archive.open("foo.zip") do |zip|
  #       # create slice buffer
  #       buf = new Slice(UInt8).new(1024)
  #
  #       # create string builder
  #       str = String.build do |b|
  #         # open file from zip
  #         zip.open("bar.txt") do |file|
  #           # read file in chunks
  #           while ((len = file.read(buf)) > 0)
  #             b.write(buf[0, len])
  #           end
  #         end
  #       end
  #
  #       # print contents of bar.txt
  #       puts "contents of bar.txt: #{str}"
  #     end
  #
  # You can also use `Zip::Archive` imperatively, like this:
  #
  #     # create foo.zip
  #     zip = Zip::Archive.create("foo.zip")
  #
  #     # add bar.txt
  #     zip.add("bar.txt", "sample contents of bar.txt")
  #
  #     # close and write zip file
  #     zip.close
  #
  class Archive
    include Enumerable(String)
    include Iterable

    protected getter zip

    # Create `Archive` instance from file *path*, pass instance to the
    # given block *block*, then close the archive when the block exits.
    #
    # Raises an exception if `Archive` could not be opened.
    #
    # ### Example
    #
    #     # open existing archive "foo.zip" and extract "bar.txt" from it
    #     Zip::Archive.open("foo.zip") do |zip|
    #       # create slice buffer
    #       buf = new Slice(UInt8).new(1024)
    #
    #       # create string builder
    #       str = String.build do |b|
    #         # open file from zip
    #         zip.open("bar.txt") do |file|
    #           # read file in chunks
    #           while ((len = file.read(buf)) > 0)
    #             b.write(buf[0, len])
    #           end
    #         end
    #       end
    #
    #       # print contents of bar.txt
    #       puts "contents of bar.txt: #{str}"
    #     end
    #
    # See Also:
    # * `#create(String, Int32)`
    def self.open(path : String, flags = 0 : Int32, &block)
      # create archive
      zip = new(path, flags)

      r = nil
      begin
        # pass archive to block
        r = yield zip
      ensure
        # close archive
        zip.close if zip.open?
      end

      # return result
      r
    end

    # Default flags for `Archive#create`
    CREATE_FLAGS = OpenFlag.flags(CREATE, EXCL).value

    # Create `Archive` instance from file *path*, pass the instance to
    # the given block *block*, then close the archive when the block
    # exits.
    #
    # Raises an exception if `Archive` could not be opened.
    #
    # ### Example
    #
    #     # create a new archive named foo.zip and populate it
    #     Zip::Archive.create("foo.zip") do |zip|
    #       # add file "/path/to/foo.txt" to archive as "bar.txt"
    #       zip.add_file("bar.txt", "/path/to/foo.txt")
    #
    #       # add file "baz.txt" with contents "hello world!"
    #       zip.add("baz.txt", "hello world!")
    #     end
    #
    # See Also:
    # * `#open(String, Int32)`
    def self.create(path : String, flags = CREATE_FLAGS : Int32, &block)
      self.open(path, flags) do |zip|
        yield zip
      end
    end

    # Create `Archive` instance from file *path*.
    #
    # Raises an exception if `Archive` could not be opened.
    #
    # ### Example
    #
    #     # create foo.zip
    #     zip = Zip::Archive.create("foo.zip")
    #
    #     # add bar.txt
    #     zip.add("bar.txt", "sample contents of bar.txt")
    #
    #     # close and write zip file
    #     zip.close
    #
    # See Also:
    # * `#open(String, Int32)`
    def self.create(path : String, flags = CREATE_FLAGS : Int32)
      new(path, flags)
    end

    # Internal constructor to create `Archive` instance from
    # `LibZip::ZipArchive` and error code.
    protected def initialize(@zip : LibZip::ZipArchive, err : Int32)
      @comment = ""
      raise Error.new(err) unless @zip != nil && ok?(err)
      @open = true
    end

    # Create a `Archive` instance from the file *path*.
    #
    # Raises an exception if `Archive` could not be opened.
    #
    # ### Example
    #
    #     # create foo.zip
    #     zip = Zip::Archive.new("foo.zip", Zip::OpenFlags::CREATE.value)
    #
    #     # add bar.txt
    #     zip.add("bar.txt", "sample contents of bar.txt")
    #
    #     # close and write zip file
    #     zip.close
    #
    def initialize(path : String, flags = 0 : Int32)
      # open from path
      zip = LibZip.zip_open(path, flags, out err)
      initialize(zip, err)
    end

    # Returns `Archive` instance from `IO::FileDescriptor` *fd*.
    #
    # Raises an exception if `Archive` could not be opened.
    #
    # TODO
    def initialize(fd : IO::FileDescriptor, flags = 0 : Int32)
      # open from fd
      zip = LibZip.zip_fdopen(fd.fd, flags, out err)
      initialize(zip, err)
    end

    # Return last archive error as an `ErrorCode` instance.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # get and print last error
    #     puts zip.error
    #
    def error : ErrorCode
      assert_open

      LibZip.zip_error_get(@zip, out err, out sys)

      if err != 0 && sys != 0
        # TODO: do something with sys error?
        # puts "sys: #{sys}"
      end

      ErrorCode.new(err)
    end

    # Clear last archive error code.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # clear last error
    #     zip.clear_error
    #
    def clear_error
      assert_open

      LibZip.zip_error_clear(@zip)
      nil
    end

    # Returns *true* if this `Archive` is open, or *false* otherwise.
    #
    # ### Example
    #
    #     # clear last error
    #     puts "zip is %s" % [zip.open? ? "open" : "closed"]
    #
    def open?
      @open
    end

    # Close this `Archive`.  If *discard* is true, then discard any
    # changes.
    #
    # Raises an exception if this `Archive` is not open or if the
    # archive could not be closed.
    #
    # ### Example
    #
    #     # close zip file
    #     zip.close
    #
    # See also: `#discard`.
    def close(discard = false : Bool)
      assert_open

      if discard
        # discard changes
        LibZip.zip_discard(@zip)
      else
        # close archive
        err = LibZip.zip_close(@zip)
        raise Error.new(err) unless ok?(err)
      end

      # mark as closed
      @open = false
    end

    # Discard any changes and close this `Archive`.  Equivalent to
    # `#close(true)`.
    #
    # Raises an exception if this `Archive` is not open or if the
    # archive could not be closed.
    #
    # ### Example
    #
    #     # close zip file and discard changes
    #     zip.discard
    #
    # See also: `#close`.
    def discard
      close(true)
    end

    # Set and return the comment for the entire archive.  Comment must
    # be encoded in ASCII or UTF-8.  Returns comment string.
    #
    # Raises an exception if this `Archive` is not open or if the
    # comment could not be set.
    #
    # ### Example
    #
    #     # set archive comment
    #     zip.comment = "this is a test comment"
    #
    def comment=(s : String) : String
      assert_open

      if LibZip.zip_set_archive_comment(@zip, s, s.bytesize) == -1
        raise Error.new(error)
      end

      # retain and return
      @comment = s
    end

    # Returns comment for the entire archive, or nil if there is no
    # comment set.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # get archive comment and print it
    #     if comment = zip.comment
    #       puts comment
    #     end
    #
    def comment(flags = 0 : Int32) : String?
      assert_open

      ptr = LibZip.zip_get_archive_comment(@zip, out len, flags)
      (ptr != nil) ? String.new(ptr, len) : nil
    end

    # Add given `Zip::Source` *source* to archive as *path* and return
    # index of new entry.
    #
    # Raises an exception if this `Archive` is not open or if *source*
    # could not be added.
    #
    # ### Example
    #
    #     # create a new string source
    #     src = Zip::StringSource.new("test string")
    #
    #     # add to archive as "foo.txt"
    #     zip.add("foo.txt", src)
    #
    # See also: `#add(String, String, Int32)`.
    def add(path : String, source : Source, flags = 0 : Int32)
      assert_open

      # add file
      r = LibZip.zip_file_add(@zip, path, source.source, flags) == -1
      raise Error.new(error) if r == -1

      # return result
      r
    end

    # Add archive entry *path* with content *body*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # add "foo.txt" to archive with body "hello from foo.txt"
    #     zip.add("foo.txt", "hello from foo.txt")
    #
    def add(path : String, body : String, flags = 0 : Int32)
      add(path, StringSource.new(self, body), flags)
    end

    # Add archive entry *path* with content *body*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # create slice
    #     slice = Slice.new(10) { |i| i + 10 }
    #
    #     # add slice to archive as "foo.txt"
    #     zip.add("foo.txt", slice)
    #
    def add(path : String, slice : Slice, flags = 0 : Int32)
      add(path, SliceSource.new(self, slice), flags)
    end

    # Add file *src_path* to archive as *dst_path*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # add "/path/to/file.txt" to archive as "foo.txt"
    #     zip.add("foo.txt", "/path/to/file.txt")
    #
    def add_file(
      dst_path : String,
      src_path : String,
      start = 0 : UInt64,
      len = -1 : Int64,
      flags = 0 : Int32
    )
      add(dst_path, FileSource.new(self, src_path, start, len), flags)
    end

    # Add directory to archive at path *path*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # add directory "some-dir" to archive
    #     zip.add_dir("some-dir")
    #
    def add_dir(path : String, flags = 0 : Int32)
      assert_open

      # add dir, check for error
      r = LibZip.zip_dir_add(@zip, path)
      raise Error.new(r) if r == -1

      # return index
      r
    end

    # Replace entry at index *index* with `Source` *source*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # replace contents of first file with "new content"
    #     zip.replace(0, StringSource.new(zip, "new content"))
    #
    def replace(index : UInt64, source : Source, flags = 0 : Int32)
      assert_open

      if LibZip.zip_file_replace(@zip, index, source.source, flags) == -1
        raise Error.new(error)
      end
    end

    # Replace entry at path *path* with `Source` *source*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # replace contents of "foo.txt" with "new content"
    #     zip.replace("foo.txt", StringSource.new(zip, "new content"))
    #
    def replace(path : String, source : Source, flags = 0 : Int32)
      assert_open

      replace(name_locate_throws(path), source, flags)
    end

    # Replace entry at index *index* with contents *body*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # replace contents of first file with "new content"
    #     zip.replace(0, "new content")
    #
    def replace(index : UInt64, body : String, flags = 0 : Int32)
      replace(index, StringSource.new(self, body), flags)
    end

    # Replace entry at path *path* with contents *body*.
    #
    # Raises an exception if this `Archive` is not open.
    #
    # ### Example
    #
    #     # replace contents of "foo.txt" with "new content"
    #     zip.replace("foo.txt", "new content")
    #
    def replace(path : String, body : String, flags  = 0 : Int32)
      replace(path, StringSource.new(self, body), flags)
    end

    # Rename file at *index* to path *new_path*.
    def rename(index : UInt64, new_path : String, flags = 0 : Int32)
      assert_open

      err = LibZip.zip_file_rename(@zip, index, new_path, flags)
      raise Error.new(err) if err == -1

      nil
    end

    # Rename file named *old_path* to new path *new_path*.
    def rename(old_path : String, new_path : String, flags = 0 : Int32)
      rename(name_locate_throws(old_path), new_path, flags)
    end

    # Delete file at given index *index*.
    def delete(index : UInt64)
      assert_open

      err = LibZip.zip_delete(@zip, index)
      raise Error.new(error) if err == -1

      nil
    end

    # Delete file at given path *path*.
    def delete(path : String)
      assert_open
      delete(name_locate_throws(path))
    end

    # Returns index of given *path*, or -1 if the given path could not
    # be found.
    def name_locate(path : String, flags = 0 : Int32)
      assert_open

      LibZip.zip_name_locate(@zip, path, flags)
    end

    # Returns index of given *path* or raises an exception if the given
    # path could not be found.
    def name_locate_throws(path : String, flags = 0 : Int32) : UInt64
      ofs = name_locate(path, flags)
      raise "unknown name: #{path}" if ofs == -1
      UInt64.new(ofs)
    end

    # Returns path of given *index*, or nil if there was an error or the
    # given index could not be found.
    def get_name(index : UInt64, flags : Int32) : String
      LibZip.zip_get_name(@zip, index, flags)
    end

    # Returns `File` instance of given *path* in `Archive`.
    def open(path : String, flags = 0 : Int32, password = nil : String?) : File
      assert_open

      # open file
      r = if password != nil
        LibZip.zip_fopen_encrypted(@zip, path, flags, password)
      else
        LibZip.zip_fopen(@zip, path, flags)
      end

      # check for error
      raise Error.new(error) if r == nil

      # return result
      File.new(self, r)
    end

    # Opens given *path* in `Archive` as a `File` instance, passes it to
    # block *block*, and closes the file when the block exits.
    def open(path : String, flags = 0 : Int32, password = nil : String?, &block)
      assert_open

      # open file
      f = open(path, flags, password)

      r = nil
      begin
        # yield file to block
        r = yield f
      ensure
        # close file if it is open
        f.close if f.open?
      end

      # return result
      r
    end

    # Returns `File` instance of given index *index* in `Archive`.
    def open(index : UInt64, flags = 0 : Int32, password = nil : String?)
      assert_open

      # open file
      r = if password != nil
        LibZip.zip_fopen_index_encrypted(@zip, index, flags, password)
      else
        LibZip.zip_fopen_index(@zip, index, flags)
      end

      # check for error
      raise Error.new(error) if r == nil

      # return result
      File.new(self, r)
    end

    # Opens index *index* in `Archive` as a `File` instance, passes it
    # to block *block*, and closes the file when the block exits.
    def open(index : UInt64, flags = 0 : Int32, password = nil : String?, &block)
      assert_open

      # open file
      f = open(index, flags)

      r = nil
      begin
        # yield file to block
        r = yield f
      ensure
        # close file if it is open
        f.close if f.open?
      end

      # return result
      r
    end

    # Read input file in chunks, pass chunks to block, and return number
    # of bytes read.
    def read(
      path            : String,
      flags = 0       : Int32,
      password = nil  : String?,
      &block          : (Slice(UInt8), Int32) -> Nil \
    ) : UInt64
      open(path, flags, password) do |file|
        # create buffer
        buf = Slice(UInt8).new(1024)
        sum = 0_u64

        # read chunks
        while ((len = file.read(buf)) > 0)
          block.call(buf, len)
          sum += len
        end

        # return result
        sum
      end
    end

    # Set the default password used when accessing encrypted files, or
    # nil for no password.
    def default_password=(password : String?)
      assert_open

      r = LibZip.zip_set_default_password(@zip, password)
      raise Error.new(error) if r == -1

      password
    end

    ########################
    # file comment methods #
    ########################

    # Returns comment of file at index *index*.
    def get_file_comment(index : UInt64, flags = 0 : Int32)
      assert_open

      ptr = LibZip.zip_file_get_comment(@zip, index, out len, flags)
      raise Error.new(error) if ptr == nil

      # return new string
      String.new(ptr, len)
    end

    # Returns comment of file at path *path*.
    def get_file_comment(path : String, flags = 0 : Int32)
      get_file_comment(name_locate_throws(path), flags)
    end

    # Set comment of file at *index* to string *comment*.
    def set_file_comment(index : UInt64, comment : String?, flags = 0 : Int32)
      assert_open

      # set comment
      err = if comment != nil
        LibZip.zip_file_set_comment(@zip, index, comment, comment.bytesize, flags)
      else
        LibZip.zip_file_set_comment(@zip, index, nil, 0, flags)
      end

      # check for error
      raise Error.new(err) if err == -1

      # return nil
      nil
    end

    # Set comment of file path *path* to string *comment*.
    def set_file_comment(path : String, comment : String?, flags = 0 : Int32)
      set_file_comment(name_locate_throws(path), comment, flags)
    end

    # Get the number of files in this archive.
    def num_entries(flags = 0 : Int32)
      assert_open

      # get count, check for error
      r = LibZip.zip_get_num_entries(@zip, flags)
      raise Error.new(error) if r == -1

      # return result
      r
    end

    ################
    # each methods #
    ################

    def each(flags = 0 : Int32, &block)
      assert_open

      num_entries(flags).times do |i|
        yield get_name(i, flags)
      end
    end

    def each(flags = 0 : Int32)
      assert_open

      # create and return iterator
      ArchiveIterator.new(self, flags)
    end

    ################
    # stat methods #
    ################

    def stat(path : String, flags = 0 : Int32) : LibZip::Stat
      assert_open

      # call stat, check for error
      err = LibZip.zip_stat(@zip, path, flags, out r)
      raise Error.new(error) if err == -1

      # return result
      r
    end

    def stat(index : LibC::Int, flags = 0 : Int32) : LibZip::Stat
      assert_open

      # call stat, check for error
      err = LibZip.zip_stat_index(@zip, index, flags, out r)
      raise Error.new(error) if err == -1

      # return result
      r
    end


    # private methods

    private def assert_open
      raise "Archive already closed" unless open?
    end

    private def ok?(err : Int32)
      err == ErrorCode::OK.value
    end
  end
end
