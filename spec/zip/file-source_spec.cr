require "../spec_helper"

describe "Zip::FileSource" do
  zip_path = "spec/tmp/file-source.zip"
  files = Dir.glob("src/zip/**/*.cr").sort!

  it "can read files from disk" do
    File.delete?(zip_path)

    # populate src zip with test files
    Zip::Archive.create(zip_path) do |zip|
      zip.compression_method = :zstd
      zip.compression_flags = 3
      files.each { |path| zip.add_file(File.basename(path), path) }
    end

    # open src zip file for reading
    Zip::Archive.open(zip_path) do |zip|
      files.each do |path|
        data = zip.open(File.basename(path), &.gets_to_end)
        data.should eq File.read(path)
      end
    end
  end
end
