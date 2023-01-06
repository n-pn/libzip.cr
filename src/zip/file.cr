require "../libzip"

# Thin `IO` wrapper for reading files from archives.  Use
# `Archive#open` to get an instance.
#
# ### Example
#
#     # open "foo.txt" in archive
#     str = zip.open("foo.txt") do |file|
#       # build result string
#       String.build |b|
#         # read file in chunks
#         file.read do |buf, len|
#           b.write(buf[0, len])
#         end
#       end
#     end
#
#     # print file contents
#     puts "file contents: #{str}"
#
class Zip::ZipFile < ::IO
  # Internal method to create a `File` instance.  Use `Archive#open`
  # instead.

  protected def initialize(@zip : Archive, @file : LibZip::ZipFileT)
  end

  # Close this `File` instance.
  #
  # Raises an exception if this `File` is not open.
  #
  # ### Example
  #
  #     # close file
  #     file.close
  #
  def close : Nil
    assert_open!

    # close file, check for error
    err = LibZip.zip_fclose(@file)
    raise Zip::Error.new(err) if err != 0

    # flag instance as closed
    @closed = true
  end

  # Read bytes into `Slice` *slice* and return number of bytes read
  # (or -1 on error).
  #
  # Raises an exception if this `File` is not open.
  #
  # ### Example
  #
  #     # create slice buffer
  #     buf = Slice(UInt8).new(10)
  #
  #     # read up to 10 bytes into buf and return number of bytes read
  #     len = file.read(buf)
  #
  def read(slice : Slice(UInt8))
    assert_open!
    LibZip.zip_fread(@file, slice, slice.bytesize)
  end

  # `File` instances are read-only so this method unconditionally
  # throws an `Exception`.
  def write(slice : Slice(UInt8)) : Nil
    raise "cannot write to Zip::File instances"
  end

  # Return last archive error as an `ErrorCode` instance.
  #
  # Raises an exception if this `File` is not open.
  #
  # ### Example
  #
  #     # get and print last error
  #     puts file.error
  #
  def error : ErrorCode
    assert_open!

    # get last error
    LibZip.zip_file_error_get(@file, out err, out unused)

    # wrap and return result
    ErrorCode.new(err)
  end

  # Return last system error for this file.
  #
  # Raises an exception if this `File` is not open.
  #
  # ### Example
  #
  #     # get and print last system error
  #     puts file.system_error
  #
  def system_error : LibC::Int
    assert_open!

    # get system error
    LibZip.zip_file_error_get(@zip, nil, out res)

    # return result
    res
  end

  private def assert_open!
    raise "file closed" if closed?
    raise "archive closed" unless @zip.open?
  end
end
