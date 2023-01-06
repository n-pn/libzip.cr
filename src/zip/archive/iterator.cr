# Lazy iterator for `Archive` instances.  Created by `Archive#each`.
class Zip::ArchiveIterator
  include Iterator(String)

  @max : Int64
  @pos : UInt64

  # Internal constructor.  Use `Archive#each` instead.
  protected def initialize(@zip : Archive, @flags : Int32 = 0)
    @max = @zip.num_entries(@flags)
    @pos = 0_u64
  end

  def next
    return stop if @pos >= @max
    result = @zip.get_name(@pos, @flags)
    @pos += 1
    result
  end

  def rewind
    @pos = 0
  end
end
