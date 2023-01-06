module Zip
  # Lazy iterator for `Archive` instances.  Created by `Archive#each`.
  class ArchiveIterator
    include Iterator(String)

    @max : Int64
    @pos : UInt64

    # Internal constructor.  Use `Archive#each` instead.
    protected def initialize(
      @zip : Archive,
      @flags : Int32 = 0
    )
      @max = @zip.num_entries(@flags)
      @pos = 0_u64
    end

    def next
      if @pos < @max
        # get result
        r = @zip.get_name(@pos, @flags)

        # increment position
        @pos += 1

        # return restul
        r
      else
        # stop iterator
        stop
      end
    end

    def rewind
      @pos = 0
    end
  end
end
