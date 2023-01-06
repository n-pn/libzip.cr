# require "../spec_helper"

# describe "Zip::DescriptorSource" do
#   it "can read files from disk" do
#     File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

#     files = Dir.glob("src/zip/**/*.cr").sort!

#     # populate src zip with test files
#     Zip::Archive.create(ZIP_PATH) do |zip|
#       files.each do |path|
#         source = Zip::DescriptorSource.new(zip, File.open(path, "r"))
#         zip.add(path, source)
#       end
#     end

#     # open src zip file for reading
#     Zip::Archive.open(ZIP_PATH) do |zip|
#       files.each do |path|
#         zip.stat(path).size.should eq File.info(path).size
#       end
#     end
#   end
# end
