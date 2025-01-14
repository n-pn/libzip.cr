require "../spec_helper"

describe "Zip::Archive" do
  describe ".create(path)" do
    zip_path = "spec/tmp/create-empty.zip"
    it "can create a new archive imperatively" do
      File.delete?(zip_path)

      # create archive, then close it
      Zip::Archive.create(zip_path).close
    rescue ex
      Log.error(exception: ex) { ex.message }
      false
    end
  end

  describe ".create(path, &block)" do
    it "can create a new archive with a block" do
      zip_path = "spec/tmp/create-block.zip"

      File.delete?(zip_path)
      Zip::Archive.create(zip_path, &.add("foo.txt", "bar"))

      true
    rescue
      false
    end

    it "can throw an error message when creating a new archive" do
      bad_path = "/dev/null/bad.zip"

      expect_raises(Zip::Error) do
        Zip::Archive.create(bad_path, &.add("foo", "bar"))
      end
    end
  end

  #
  #   describe "#open(IO::Descriptor, &block)" do
  #     it "can open a zip from a file descriptor" do
  #       # remove test zip
  #       File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)
  #
  #       # create zip from descriptor
  #       File.open(ZIP_PATH, "w+") do |file|
  #         Zip::Archive.open(file) do |zip|
  #           zip.add("foo.txt", "bar")
  #           # FIXME: currently we crash after this (on zip.close)
  #         end
  #       end
  #
  #       # open generated zip
  #       Zip::Archive.open(ZIP_PATH) do |zip|
  #         String.build do |b|
  #           zip.read("foo.txt") do |buf, len|
  #             b.write(buf[0, len])
  #           end
  #         end.should eq "bar"
  #       end
  #     end
  #   end
  #

  describe "#error" do
    it "can get the last archive error" do
      zip_path = "spec/tmp/with-error.zip"
      File.delete?(zip_path)
      Zip::Archive.create(zip_path, &.error)
    end
  end

  describe "#add(path, string)" do
    it "can add a file from a string" do
      zip_path = "spec/tmp/add-string.zip"
      File.delete?(zip_path)
      Zip::Archive.create(zip_path, &.add("foo.txt", "bar"))
    end
  end

  describe "#comment" do
    it "can set an archive comment" do
      zip_path = "spec/tmp/has-comment.zip"
      File.delete?(zip_path)

      Zip::Archive.create(zip_path) do |zip|
        # set comment
        zip.comment = "foo"

        # add at least one file
        zip.add("foo.txt", "bar")
      end

      Zip::Archive.open(zip_path) do |zip|
        zip.comment.should eq "foo"
      end
    end
  end

  describe "#name_locate" do
    it "can find a file by name" do
      zip_path = "spec/tmp/name-locate.zip"
      File.delete?(zip_path)

      Zip::Archive.create(zip_path) do |zip|
        # add at least one file
        zip.add("foo.txt", "bar")
      end

      Zip::Archive.open(zip_path) do |zip|
        zip.name_locate("foo.txt").should eq 0
      end
    end
  end

  describe "#open" do
    it "can open and read files" do
      # remove test zip
      File.delete?(ZIP_PATH)

      # populate zip with test files
      Zip::Archive.create(ZIP_PATH) do |zip|
        TEST_FILES.each do |file|
          zip.add(file, file)
        end
      end

      # read test files from zip
      Zip::Archive.open(ZIP_PATH) do |zip|
        TEST_FILES.each do |path|
          zip.open(path, &.gets_to_end).should eq path
        end
      end
    end
  end

  describe "#read(&block)" do
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
          zip.read(path).should eq path
        end
      end
    end
  end

  describe "#read" do
    zip_path = "spec/zip/can-read.zip"

    it "can read a complete file" do
      # remove test zip
      File.delete?(zip_path)

      # populate zip with test files
      Zip::Archive.create(zip_path) do |zip|
        TEST_FILES.each { |test| zip.add(test, test) }
      end

      # read test files from zip
      Zip::Archive.open(zip_path) do |zip|
        TEST_FILES.each do |path|
          zip.read(path).should eq path
        end
      end
    end
  end

  describe "#stat" do
    zip_path = "spec/zip/read-stats.zip"

    it "can stat files" do
      # remove test zip
      File.delete?(zip_path)

      Zip::Archive.create(zip_path) do |zip|
        TEST_FILES.each do |file|
          zip.add(file, file)
        end
      end

      Zip::Archive.open(zip_path) do |zip|
        TEST_FILES.each do |path|
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

        # iterate names 2 at a time
        names.first(2).each do |name|
          TEST_FILES.includes?(name).should eq true
        end
      end
    end
  end
end
