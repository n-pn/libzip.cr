require "../libzip"
require "./constants"
require "./archive/iterator"

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
#     # read "bar.txt" as string from "foo.zip"
#     str = Zip::Archive.open("foo.zip") do |zip|
#       String.new(zip.read("bar.txt"))
#     end
#
#     # print contents of bar.txt
#     puts "contents of bar.txt: #{str}"
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
class Zip::Archive
  include Enumerable(String)
  include Iterable(String)

  # Create `Archive` instance from file *path*, pass instance to the
  # given block *block*, then close the archive when the block exits.
  #
  # Raises an exception if `Archive` could not be opened.
  #
  # ### Example
  #
  #     # open existing archive "foo.zip" and extract "bar.txt" from it
  #     Zip::Archive.open("foo.zip") do |zip|
  #       # create string builder
  #       str = String.build do |b|
  #         # open file from zip
  #         zip.read("bar.txt") do |buf, len|
  #           b.write(buf[0, len])
  #         end
  #       end
  #
  #       # print contents of bar.txt
  #       puts "contents of bar.txt: #{str}"
  #     end
  #
  def self.open(path : String, flags : Int32 = 0, &block)
    open_zip(new(path, flags)) { |zip| yield zip }
  end

  # Create `Archive` instance from `IO::FileDescriptor` *fd*, pass
  # instance to the given block *block*, then close the archive when
  # the block exits.
  #
  # Raises an exception if `Archive` could not be opened.
  #
  # ### Example
  #
  #     # open existing archive "foo.zip" and extract "bar.txt" from it
  #     Zip::Archive.open("foo.zip") do |zip|
  #       # create string builder
  #       str = String.build do |b|
  #         # open file from zip
  #         zip.read("bar.txt") do |buf, len|
  #           b.write(buf[0, len])
  #         end
  #       end
  #
  #       # print contents of bar.txt
  #       puts "contents of bar.txt: #{str}"
  #     end
  #
  def self.open(fd : IO::FileDescriptor, flags : Int32 = 0, &block)
    open_zip(new(fd, flags)) { |zip| yield zip }
  end

  private def self.open_zip(zip : self, &block)
    yield zip
  ensure
    zip.close if zip.open?
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
  def self.create(path : String, flags : Int32 = CREATE_FLAGS, &block)
    self.open(path, flags) { |zip| yield zip }
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
  def self.create(path : String, flags : Int32 = CREATE_FLAGS)
    new(path, flags)
  end

  protected getter zip : LibZip::ZipT
  @open = true
  @comment = ""

  # Internal constructor to create `Archive` instance from
  # `LibZip::ZipArchive` and error code.
  protected def initialize(@zip : LibZip::ZipT, err : Int32)
    raise Error.new(err) unless @zip != nil && ok?(err)
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
  def initialize(path : String, flags : Int32 = 0)
    # open from path
    zip = LibZip.zip_open(path, flags, out err)
    initialize(zip, err)
  end

  # Returns `Archive` instance from `IO::FileDescriptor` *fd*.
  #
  # Raises an exception if `Archive` could not be opened.
  #
  # FIXME: This method does not currently work (see spec for details).
  def initialize(fd : IO::FileDescriptor, flags : Int32 = 0)
    # create new fd
    # (attempt to work around SEGV on Archive#close, doesn't work)
    new_fd = LibC.dup(fd.fd)
    raise "couldn't dup fd" if new_fd == -1

    # open from fd
    zip = LibZip.zip_fdopen(new_fd, flags, out err)
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
    assert_open!

    LibZip.zip_error_get(@zip, out err, out unused)

    # wrap and return result
    ErrorCode.new(err)
  end

  # Return last system error.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # get and print last system error
  #     puts zip.system_error
  #
  def system_error : LibC::Int
    assert_open!

    # get system error
    LibZip.zip_error_get(@zip, out unused, out r)

    # return result
    r
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
    assert_open!

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
  def close(discard : Bool = false)
    assert_open!

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
  def comment=(str : String) : String
    assert_open!

    status = LibZip.zip_set_archive_comment(@zip, str, str.bytesize)
    raise Error.new(error) if status == -1

    # retain and return
    @comment = str
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
  def comment(flags : Int32 = 0) : String?
    assert_open!

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
  def add(fname : String, source : Source, flags : LibZip::Flags = 0) : Int64
    assert_open!

    index = LibZip.zip_file_add(@zip, fname, source, flags)
    index >= 0 ? index : raise Error.new(self.error)
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
  def add(path : String, body : String, flags : UInt32 = 0_u32)
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
  def add(path : String, slice : Slice, flags : UInt32 = 0_u32)
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
  def add_file(dst_path : String, src_path : String,
               start : UInt64 = 0_u64, len : Int64 = -1_i64,
               flags : UInt32 = 0_u32)
    add(dst_path, FileSource.new(self, src_path, start, len), flags)
  end

  # Add file *path* to archive as *path*.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # add "/path/to/file.txt" to archive
  #     zip.add_file("/path/to/file.txt")
  #
  def add_file(path : String,
               start : UInt64 = 0_u64, len : Int64 = -1_i64,
               flags : UInt32 = 0_u32)
    add_file(path, path, start, len, flags)
  end

  # Add directory to archive at path *path*.
  #
  # Raises an exception if this `Archive` is not open, or if dir could
  # not be added.
  #
  # ### Example
  #
  #     # add directory "some-dir" to archive
  #     zip.add_dir("some-dir")
  #
  def add_dir(path : String, flags : Int32 = 0)
    assert_open!

    # add dir, check for error
    index = LibZip.zip_dir_add(@zip, path)
    raise Error.new(index) if index < 0

    index
  end

  # Replace entry at index *index* with `Source` *source*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be replaced.
  #
  # ### Example
  #
  #     # replace contents of first file with "new content"
  #     zip.replace(0, StringSource.new(zip, "new content"))
  #
  def replace(index : UInt64, source : Source, flags : Int32 = 0)
    assert_open!

    if LibZip.zip_file_replace(@zip, index, source.source.not_nil!, flags) == -1
      raise Error.new(error)
    end
  end

  # Replace entry at path *path* with `Source` *source*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be replaced.
  #
  # ### Example
  #
  #     # replace contents of "foo.txt" with "new content"
  #     zip.replace("foo.txt", StringSource.new(zip, "new content"))
  #
  def replace(path : String, source : Source, flags : Int32 = 0)
    assert_open!

    replace(name_locate_throws(path), source, flags)
  end

  # Replace entry at index *index* with contents *body*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be replaced.
  #
  # ### Example
  #
  #     # replace contents of first file with "new content"
  #     zip.replace(0, "new content")
  #
  def replace(index : UInt64, body : String, flags : Int32 = 0)
    replace(index, StringSource.new(self, body), flags)
  end

  # Replace entry at path *path* with contents *body*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be replaced.
  #
  # ### Example
  #
  #     # replace contents of "foo.txt" with "new content"
  #     zip.replace("foo.txt", "new content")
  #
  def replace(path : String, body : String, flags : Int32 = 0)
    replace(path, StringSource.new(self, body), flags)
  end

  # Rename file at *index* to path *new_path*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be renamed.
  #
  # ### Example
  #
  #     # rename first file to "new-file.txt"
  #     zip.rename(0, "new-file.txt")
  #
  def rename(index : UInt64, new_path : String, flags : Int32 = 0)
    assert_open!

    err = LibZip.zip_file_rename(@zip, index, new_path, flags)
    raise Error.new(err) if err == -1

    nil
  end

  # Rename file named *old_path* to new path *new_path*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be renamed.
  #
  # ### Example
  #
  #     # rename "foo.txt" to "new-file.txt"
  #     zip.rename("foo.txt", "new-file.txt")
  #
  def rename(old_path : String, new_path : String, flags : Int32 = 0)
    rename(name_locate_throws(old_path), new_path, flags)
  end

  # Delete file at given index *index*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be deleted.
  #
  # ### Example
  #
  #     # delete first file in archive
  #     zip.delete(0)
  #
  def delete(index : UInt64)
    assert_open!

    err = LibZip.zip_delete(@zip, index)
    raise Error.new(error) if err == -1

    nil
  end

  # Delete file at given path *path*.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be deleted.
  #
  # ### Example
  #
  #     # delete "foo.txt" from archive
  #     zip.delete("foo.txt")
  #
  def delete(path : String)
    assert_open!
    delete(name_locate_throws(path))
  end

  # Returns index of given *path*, or -1 if the given path could not
  # be found.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # get index of "foo.txt"
  #     index = zip.name_locate("foo.txt")
  #
  def name_locate(path : String, flags : Int32 = 0) : Int64
    assert_open!

    LibZip.zip_name_locate(@zip, path, flags)
  end

  # Returns index of given *path* or raises an exception if the given
  # path could not be found.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # get index of "foo.txt" or raise exception if "foo.txt" could
  #     # not be found
  #     index = zip.name_locate_throws("foo.txt")
  #
  def name_locate_throws(path : String, flags : Int32 = 0) : UInt64
    ofs = name_locate(path, flags)
    raise "unknown name: #{path}" if ofs == -1
    UInt64.new(ofs)
  end

  # Returns path of given *index*, or nil if there was an error or the
  # given index could not be found.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # get name of first file in archive
  #     path = zip.get_name(0)
  #
  def get_name(index : UInt64, flags : Int32) : String
    String.new(LibZip.zip_get_name(@zip, index, flags))
  end

  private def do_open(file : ZipFile, &block)
    yield file
  ensure
    file.close unless file.closed?
  end

  # Open *path* in `Archive` and return it as `File` instance.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be opened.
  #
  # ### Example
  #
  #     # declare buffer
  #     buf = Slice(UInt8).new(10)
  #
  #     # open "foo.txt"
  #     file = zip.open("foo.txt")
  #
  #     # read up to 10 bytes of contents
  #     len = file.read(buf)
  #
  #     # close "foo.txt"
  #     file.close
  #
  def open(fname : String, flags : Int32 = 0, password : String? = nil) : ZipFile
    assert_open!

    # open file
    if password != nil
      file = LibZip.zip_fopen_encrypted(self, fname, flags, password)
    else
      file = LibZip.zip_fopen(self, fname, flags)
    end

    file ? ZipFile.new(self, file) : raise Error.new(self.error)
  end

  # Opens given *path* in `Archive` as a `File` instance, passes it to
  # block *block*, and closes the file when the block exits.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be opened.
  #
  # ### Example
  #
  #     # read up to 10 bytes from "foo.txt"
  #     zip.open("foo.txt") do |file|
  #       # declare buffer
  #       buf = Slice(UInt8).new(10)
  #
  #       # read up to 10 bytes of contents
  #       len = file.read(buf)
  #
  #       # return buffer
  #       buf[0, len]
  #     end
  #
  def open(fname : String, flags : Int32 = 0, password : String? = nil, &block)
    do_open(open(fname, flags, password)) { |file| yield file }
  end

  # Returns `File` instance of given index *index* in `Archive`.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be opened.
  #
  # ### Example
  #
  #     # declare buffer
  #     buf = Slice(UInt8).new(10)
  #
  #     # open first file in archive
  #     file = zip.open(0)
  #
  #     # read up to 10 bytes of contents
  #     len = file.read(buf)
  #
  #     # close "foo.txt"
  #     file.close
  #
  def open(index : UInt64, flags : Int32 = 0, password : String? = nil)
    assert_open!

    # open file
    if password != nil
      file = LibZip.zip_fopen_index_encrypted(self, index, flags, password)
    else
      file = LibZip.zip_fopen_index(self, index, flags)
    end

    file ? ZipFile.new(self, file) : raise Error.new(self.error)
  end

  # Opens index *index* in `Archive` as a `File` instance, passes it
  # to block *block*, and closes the file when the block exits.
  #
  # Raises an exception if this `Archive` is not open, or if file
  # could not be opened.
  #
  # ### Example
  #
  #     # open first file in archive
  #     zip.open(0) do |file|
  #       # declare buffer
  #       buf = Slice(UInt8).new(10)
  #
  #       # read up to 10 bytes of contents
  #       len = file.read(buf)
  #
  #       # return buffer
  #       buf[0, len]
  #     end
  #
  def open(index : UInt64, flags : Int32 = 0, password : String? = nil, &block)
    do_open(open(index, flags, password)) { |file| yield file }
  end

  # Read contents of file *fname* and return it as a `Slice(UInt8)`.
  #
  # Raises an exception if this `Archive` is not open, if file
  # could not be opened, or if the file could not be read.
  #
  # ### Example
  #
  #     # read "foo.txt" from zip file as string
  #     str = String.new(zip.read_bytes("foo.txt"))
  #
  def read_bytes(fname : String, flags : Int32 = 0_i32, password : String? = nil) : Bytes
    open(fname, flags, password, &.getb_to_end)
  end

  # Read contents of file *fname* and return it as a `String.
  #
  # Raises an exception if this `Archive` is not open, if file
  # could not be opened, or if the file could not be read.
  #
  # ### Example
  #
  #     # read "foo.txt" from zip file as string
  #     str = zip.read("foo.txt")
  #
  def read(fname : String, flags : Int32 = 0_i32, password : String? = nil) : String
    open(fname, flags, password, &.gets_to_end)
  end

  # Set the default password used when accessing encrypted files, or
  # nil for no password.
  #
  # Raises an exception if this `Archive` is not open, or if the
  # default password could not be set.
  #
  # ### Example
  #
  #     # set default password to "foobar"
  #     zip.default_password = "foobar"
  #
  def default_password=(password : String?)
    assert_open!
    err = LibZip.zip_set_default_password(@zip, password)
    err == -1 ? password : raise Error.new(self.error)
  end

  ########################
  # file comment methods #
  ########################

  # Returns comment of file at index *index* or nil if there is no
  # comment set.
  #
  # Raises an exception if this `Archive` is not open, or if there was
  # an error fetching the file comment.
  #
  # ### Example
  #
  #     # get comment of first file in archive
  #     zip.get_file_comment(0)
  #
  #
  def get_file_comment(index : UInt64, flags : Int32 = 0) : String?
    assert_open!

    # clear last error
    clear_error

    # get file comment, and raise exception if ther was an error
    ptr = LibZip.zip_file_get_comment(@zip, index, out len, flags)
    raise Error.new(error) if ptr == nil && error.value != 0

    # return new string, or nil if there was no comment
    ptr ? String.new(ptr, len) : nil
  end

  # Returns comment of file at path *path*, or nil if there was no
  # comment set.
  #
  # Raises an exception if this `Archive` is not open, or if there was
  # an error fetching the file comment.
  #
  # ### Example
  #
  #     # get comment of "foo.txt"
  #     zip.get_file_comment("foo.txt")
  #
  def get_file_comment(path : String, flags : Int32 = 0)
    get_file_comment(name_locate_throws(path), flags)
  end

  # Set comment of file at *index* to string *comment*.
  #
  # Raises an exception if this `Archive` is not open, or if there was
  # an error setting the file comment.
  #
  # ### Example
  #
  #     # set comment of first file to "example comment"
  #     zip.set_file_comment(0, "example comment")
  #
  def set_file_comment(index : UInt64, comment : String?, flags : Int32 = 0) : Nil
    assert_open!

    len = comment.try(&.bytesize) || 0
    err = LibZip.zip_file_set_comment(@zip, index, comment, len, flags)
    raise Error.new(err) if err == -1
  end

  # Set comment of file path *path* to string *comment*.
  #
  # Raises an exception if this `Archive` is not open, or if there was
  # an error setting the file comment.
  #
  # ### Example
  #
  #     # set comment of "foo.txt" to "example comment"
  #     zip.set_file_comment("foo.txt", "example comment")
  #
  def set_file_comment(path : String, comment : String?, flags : Int32 = 0)
    set_file_comment(name_locate_throws(path), comment, flags)
  end

  # Get the number of files in this archive.
  #
  # Raises an exception if this `Archive` is not open, or if there was
  # an error counting the number of entries.
  #
  # ### Example
  #
  #     # get number of entries
  #     count = zip.num_entries
  #
  def num_entries(flags : Int32 = 0) : Int64
    assert_open!

    # get count, check for error
    r = LibZip.zip_get_num_entries(@zip, flags)
    raise Error.new(error) if r == -1

    # return result
    r
  end

  ################
  # each methods #
  ################

  # Iterate over names of files in archive.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # get file names
  #     file_names = [] of String
  #     zip.each { |name| file_names << name }
  #
  def each(flags : Int32 = 0, &block : String ->)
    assert_open!

    (0_u64 + num_entries(flags)).times do |i|
      yield get_name(i, flags)
    end
  end

  # Return iterator over names of files in archive.
  #
  # Raises an exception if this `Archive` is not open.
  #
  # ### Example
  #
  #     # create name iterator
  #     names = zip.each
  #
  #     # iterate names 2 at a time
  #     names.take(2).each do |name|
  #       puts name
  #     end
  #
  def each(flags : Int32 = 0)
    assert_open!

    # create and return iterator
    ArchiveIterator.new(self, flags)
  end

  ################
  # stat methods #
  ################

  # Return stat information about `path` as a `LibZip::Stat`
  # structure.
  #
  # Raises an exception if this `Archive` is not open or if file could
  # not be statted.
  #
  # ### Example
  #
  #     # get size of "foo.txt"
  #     st = zip.stat("foo.txt")
  #     puts "file size = #{st.size}"
  #
  def stat(path : String, flags : Int32 = 0) : LibZip::ZipStatT
    assert_open!

    # call stat, check for error
    err = LibZip.zip_stat(@zip, path, flags, out r)
    raise Error.new(error) if err == -1

    # return result
    r
  end

  # Return stat information about file at index *index* as a
  # `LibZip::Stat` structure.
  #
  # Raises an exception if this `Archive` is not open or if file could
  # not be statted.
  #
  # ### Example
  #
  #     # get size of first file in archive
  #     st = zip.stat(0)
  #     puts "file size = #{st.size}"
  #
  def stat(index : LibC::Int, flags : Int32 = 0) : LibZip::Stat
    assert_open!

    # call stat, check for error
    err = LibZip.zip_stat_index(@zip, index, flags, out r)
    raise Error.new(error) if err == -1

    # return result
    r
  end

  def to_unsafe
    @zip
  end

  ###################
  # private methods #
  ###################

  # Raise exception if archive is closed
  private def assert_open!
    raise "Archive already closed" unless self.open?
  end

  # Return true if error indicates success.
  private def ok?(err : Int32)
    err == ErrorCode::OK.value
  end
end
