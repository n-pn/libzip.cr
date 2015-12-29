require "./spec_helper"

ZIP_PATH = "spec/out/test.zip"
BAD_PATH = "/dev/null/bad.zip"
TEST_FILES = %w{foo.txt bar.png baz.jpeg blum.html}
TEST_STRING = "This is a test string."

class TestProcSource < Zip::ProcSource
  property pos
  property data

  def initialize(zip, data)
    # reset position and cache data slice
    @pos = 0
    @data = data.to_slice

    super(zip, ->(
      action    : Zip::Action,
      slice     : Slice(UInt8),
      user_data : Void* \
    ) {
      # cast data pointer back to "self"
      me = user_data as TestProcSource

      # switch on action, then coerce result to i64
      0_i64 + case action
      when .open?
        # reset position
        me.pos = 0

        # return 0
        0
      when .read?
        if me.pos < data.bytesize
          # get shortest length
          len = me.data.bytesize - me.pos
          len = slice.bytesize if slice.bytesize < len

          if len > 0
            # copy string data to slice and increment position
            slice.copy_from(me.data[me.pos, len].to_unsafe, len)
            me.pos += len
          end

          # return length
          len
        else
          # puts "read: done"
          0
        end
      when .stat?
        # get size of stat struct
        st_size = sizeof(Zip::LibZip::Stat)

        # create and populate stat struct
        st = Zip::LibZip::Stat.new(
          valid:  Zip::StatFlag::SIZE.value,
          size:   me.data.bytesize
        )

        # copy populated struct to slice
        slice.copy_from(pointerof(st) as Pointer(UInt8), st_size)

        # return sizeof stat
        st_size
      else
        # for all other actions, do nothing
        0
      end
    }, self as Pointer(Void))
  end
end

describe "Zip" do
  describe "LibZip" do
    it "links properly to libzip" do
      zip = Zip::LibZip.zip_open("test.zip", 0, nil)
      Zip::LibZip.zip_discard(zip)
    end
  end

  describe "Archive" do
    describe ".create(path)" do
      it "can create a new archive imperatively" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # create archive, then close it
        zip = Zip::Archive.create(ZIP_PATH).close
      end
    end

    describe ".create(path, &block)" do
      it "can create a new archive with a block" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        Zip::Archive.create(ZIP_PATH) do |zip|
          zip.add("foo.txt", "bar")
        end

        # return success
        true
      end

      it "can throw an error message when creating a new archive" do
        expect_raises(Zip::Error) do
          Zip::Archive.create(BAD_PATH) do |zip|
            zip.add("foo", "bar")
          end
        end
      end
    end

    describe "#error" do
      it "can get the last archive error" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        Zip::Archive.create(ZIP_PATH) do |zip|
          zip.error
        end
      end
    end

    describe "#add(path, string)" do
      it "can add a file from a string" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # create archive
        Zip::Archive.create(ZIP_PATH) do |zip|
          zip.add("foo.txt", "bar")
        end
      end
    end

    describe "#comment" do
      it "can set an archive comment" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        Zip::Archive.create(ZIP_PATH) do |zip|
          # set comment
          zip.comment = "foo"

          # add at least one file
          zip.add("foo.txt", "bar")
        end

        Zip::Archive.open(ZIP_PATH) do |zip|
          zip.comment.should eq "foo"
        end

        # return success
        true
      end
    end

    describe "#name_locate" do
      it "can find a file by name" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        Zip::Archive.create(ZIP_PATH) do |zip|
          # add at least one file
          zip.add("foo.txt", "bar")
        end

        Zip::Archive.open(ZIP_PATH) do |zip|
          zip.name_locate("foo.txt").should eq 0
        end
      end
    end

    describe "#open" do
      it "can open and read files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end
        end

        # read test files from zip
        Zip::Archive.open(ZIP_PATH) do |zip|
          # create buffer
          buf = Slice(UInt8).new(1024)

          TEST_FILES.each do |path|
            zip.open(path) do |fh|
              String.build do |b|
                while ((len = fh.read(buf)) > 0)
                  b.write(buf[0, len])
                end
              end.should eq path
            end
          end
        end
      end
    end

    describe "#read" do
      it "can read chunks of a file" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end
        end

        # read test files from zip
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            String.build do |b|
              zip.read(path) do |buf, len|
                b.write(buf[0, len])
              end
            end.should eq path
          end
        end
      end
    end

    describe "#stat" do
      it "can stat files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end
        end

        # open zip file and check file sizes
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            st = zip.stat(path)
            zip.stat(path).size.should eq path.bytesize
          end
        end
      end
    end

    describe "#replace" do
      it "can replace files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end
        end

        # open zip file and replace test files' contents
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.replace(path, TEST_STRING)
          end
        end

        # open zip file
        Zip::Archive.open(ZIP_PATH) do |zip|
          # check test files sizes
          TEST_FILES.each do |path|
            st = zip.stat(path)
            zip.stat(path).size.should eq TEST_STRING.bytesize
          end
        end
      end
    end

    describe "#rename" do
      it "can rename files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end
        end

        # open zip file and rename test files
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.rename(path, "foo#{path}")
          end
        end

        # open zip file and check for renamed files
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.stat("foo#{path}").size.should eq path.bytesize
          end
        end
      end
    end

    describe "#delete" do
      it "can delete files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            zip.add(file, file)
          end

          # add one more file (so there is at least one)
          zip.add("random.txt", "random")
        end

        # open zip file and delete test files
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.delete(path)
          end
        end

        # open zip file and check for deleted files
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.name_locate(path).should eq -1
          end
        end
      end
    end

    describe "#set_file_comment" do
      it "can set and get file comments" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            # add file
            zip.add(file, file)

            # set comment
            zip.set_file_comment(file, file + "fdsa")
          end
        end

        # open zip file and check file comments
        Zip::Archive.open(ZIP_PATH) do |zip|
          TEST_FILES.each do |path|
            zip.get_file_comment(path).should eq path + "fdsa"
          end
        end
      end
    end

    describe "#each(&block)" do
      it "can iterate over files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            # add file
            zip.add(file, file)

            # add file
            zip.set_file_comment(file, file + "fdsa")
          end
        end

        # open zip file and enumerate names
        Zip::Archive.open(ZIP_PATH) do |zip|
          zip.each do |path|
            TEST_FILES.includes?(path).should eq true
          end
        end
      end
    end

    describe "#each" do
      it "can iterate lazily over files" do
        # remove test zip
        File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

        # populate zip with test files
        Zip::Archive.create(ZIP_PATH) do |zip|
          TEST_FILES.each do |file|
            # add file
            zip.add(file, file)

            # add file
            zip.set_file_comment(file, file + "fdsa")
          end
        end

        # open zip file and iterate names lazily
        Zip::Archive.open(ZIP_PATH) do |zip|
          # create iterator
          names = zip.each

          names.take(2).to_a.each do |name|
            TEST_FILES.includes?(name).should eq true
          end
        end
      end
    end
  end

  describe "ProcSource" do
    it "can read files from a custom source" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # populate zip with test file
      Zip::Archive.create(ZIP_PATH) do |zip|
        # add "text.txt" from custom Zip::ProcSource
        zip.add("test.txt", TestProcSource.new(zip, TEST_STRING))
      end

      # open zip file for reading
      Zip::Archive.open(ZIP_PATH) do |zip|
        # read "test.txt", then compare it to TEST_STRING
        String.build do |b|
          zip.read("test.txt") do |buf, len|
            b.write(buf[0, len])
          end
        end.should eq TEST_STRING
      end
    end
  end
end
