require 'rubygems'
require 'avro'

# Open items.avro file in read mode
file = File.open('/Users/avd/filec8666c004f92.avro', 'rb')

# Create an instance of DatumReader 
reader = Avro::IO::DatumReader.new()

# Equivalent to DataFileReader instance creation in Java
dr = Avro::DataFile::Reader.new(file, reader)

# For each record type in the input file prints the fields mentioned 
# in print command on console. Each output field is tab seperated 
dr.each {|record|
        print record
        }


# Close the input file
dr.close
