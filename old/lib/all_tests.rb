require 'test/unit'

Dir['*_test.rb'].each do |test_file_name|
  print "Adding ", test_file_name, "\n"
  require test_file_name.chomp(".rb")
end
