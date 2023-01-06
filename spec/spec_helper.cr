require "log"
require "spec"
require "../src/zip"

ZIP_PATH    = "spec/tmp/test.zip"
BAD_PATH    = "/dev/null/bad.zip"
TEST_FILES  = %w{foo.txt bar.png baz.jpeg blum.html}
TEST_STRING = "This is a test string."
