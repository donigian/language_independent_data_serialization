# Equivalant to importing required packages in Java
require 'rubygems'
require 'avro'

# Below line creates items.avro file if it is not present otherwise opens it in write mode
file = File.open('items.avro', 'wb')  

# Opens item.avsc in read mode and parses the schema.
schema = Avro::Schema.parse(File.open("item.avsc", "rb").read)

# Creates DatumWriter instance with required schema.
writer = Avro::IO::DatumWriter.new(schema)

# Below dw is equivalent to DataFileWriter instance in Java API
dw = Avro::DataFile::Writer.new(file, writer, schema)

# write each record into output avro data file
dw<< {"name" => "Desktop", "description" => "Office and Personal Usage", "price" => 30000}
dw<< {"name" => "Laptop", "price" => 50000}
dw<< {"name" => "Tablet", "description" => "Personal Usage"}
dw<< {"name" => "Mobile", "description" => "Personal Usage", "price" => 10000}
dw<< {"name" => "Notepad", "price" => 20000}
dw<< {"name" => "SmartPhone", "description" => "Multipurpose", "price" => 40000}

# close the avro data file
dw.close
