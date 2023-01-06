require "../spec_helper"

describe "LibZip" do
  it "links properly to libzip" do
    zip = LibZip.zip_open("test.zip", 0, nil)
    LibZip.zip_discard(zip)
  end
end
