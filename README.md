There are use cases when you need a mechanism to exchange/store data structures, memory buffer, object state over the network or store it on persisted disk. Before discussing solutions, let's take a look at our requirements for this language independent mechanism.


### Requirements: What do we want?

+ Ability to read/write from various programming languages (say R & Ruby for starters)
+ Ability to support optional fields, model versioning, complex data types, data compression etc...
+ Easy & speedy development
+ Available open source libraries
+ Ability to grow model 
+ Flexibility to support different data structures
+ Something simple
+ Something performant

Though we could implement our own data serialization mechanism, this is a common problem in industry that has been solved. [Protocol Buffer](https://github.com/google/protobuf), [Thrift](https://github.com/apache/thrift) and [Avro](https://github.com/apache/avro) are several open source projects designed to save you time/effort of building out your own custom serializer. 

Let's look at a comparison between the open source alternatives.

| Feature   | Avro    |  Thrift & Protocol Buffer |
|----------|:-------------:|------:|
|Dynamic schema        |  Yes  | No |
| JSON Schema  |  Yes  | No, Proprietary DSL|
| No compilation  |  Yes  | No |
| No need to declare IDs |  Yes  | No |
| Code generation required| No | Yes|
| Compressible & Splittable | Yes | No|
| Interoperable w/ big data frameworks  |  Yes  | No |

The chart illustrates important reasons why `Avro` is ahead of the pack. `Avro` provides rich data structures including the following:

##Avro Schemas
Defined in JSON, it's a self-describing definition of our data model(s). 

Contains the following details

+ type of file (record by default)
+ location of record
+ name of the record
+ fields in the record with their corresponding data types

Using these schemas, you can store serialized values in binary format using less
space. These values are stored without any metadata, unlike JSON/XML.

| Primitive Data Types | Description |
|----------|:-------------:|------:|
|null| Null is a type having no value
|int 32-bit | signed integer
|long |64-bit signed integer
|float | single precision (32-bit) IEEE 754 floating-point number
| double | double precision (64-bit) IEEE 754 floating-point number
|bytes| sequence of 8-bit unsigned bytes
|string |Unicode character sequence


| Complex Data Types | Description |
|----------|:-------------:|------:|
|Record | collection of multiple attributes
|Enum | list of items in a collection
|Arrays| duh
|Unions | field which has 1 or more datatypes (represented by JSON arrays)
|Fixed| fixed sized field used to store binary data (Fixed format)

Let's illustrate these concepts with an example schema:
```
{
 "type" : "record",
 "name" : "Item",
 "namespace" : "example.avro",
 "fields" : [
              {"name": "name", "type": "string"},
              {"name": "description", "type":["string", "null"]},
              {"name": "price", "type":["double", "null"]}
            ]
}
```

##Avro Data File
The `Avro Data File (.avro)`, stores data along with its schema in the metadata section. This is a powerful feature which separates `Avro` from the alternatives since no code generation is needed after schema has been defined.

## Install Avro in R enviornment
`ravro` R package allows reading and writing of files in the avro serialization format.
To install Avro in R-Studio, complete the following steps:
```
1) install.packages(c("Rcpp","rjson","bit64"))  # installs dependencies
2) system("java -version") # ensure you have Java installed and is available via PATH env variable.
3) wget https://github.com/RevolutionAnalytics/ravro/blob/1.0.4/build/ravro_1.0.4.tar.gz?raw=true # ravro binary
4) R CMD INSTALL ravro_1.0.4.tar.gz # install ravro
5) R CMD check ravro_1.0.4.tar.gz   # verify that the package is working correctly on your system 
```

## Install Avro in your Ruby enviornment. 
`sudo gem install avro`


##Avro Serialization 
You can read an Avro schema into a program either by **generating a class
corresponding to a schema** or by **using the parsers library**. In Avro, data is always stored with its corresponding schema so we can always read a schema
without code generation.

The use cases below will be using the parsers library method since it doesn't require any code generation, as the `Avro` schema provides dynamic types.

The source code for the following use cases is available in this repo.

###Use case: Write from Ruby, read from R 
```
Avro Schema (item.avsc) ===> Ruby writer (generate_data_from_ruby.rb) ===> R reader (read_data_generated_from_ruby.R)
```

```
# generate_data_from_ruby.rb
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
```

```
# read_data_generated_from_ruby.R
library('ravro')

# Read in the data
item_avro <- read.avro('./items.avro')
item_avro
```


###Use case: Write from Ruby, read from Ruby
```
Avro Schema (item.avsc) ===> Ruby writer (generate_data_from_ruby.rb) ===> Ruby reader (read_data_from_ruby.rb)
```


```
# read_data_from_ruby.rb
require 'rubygems'
require 'avro'

# Open items.avro file in read mode
file = File.open('items.avro', 'rb')

# Create an instance of DatumReader
reader = Avro::IO::DatumReader.new()

# Equivalent to DataFileReader instance creation in Java
dr = Avro::DataFile::Reader.new(file, reader)

# For each record type in the input file prints the fields mentioned
# in print command on console. Each output field is tab seperated
dr.each {|record|
         print record["name"],"\t",record["description"],"\t",record["price"],"\n"
        }


# Close the input file
dr.close
```



###Use case: Write from R, read from Ruby
```
Avro Schema (iris.avsc) ===> R writer (generate_data_from_r.R) ===> Ruby reader (read_data_from_r.rb)
```


```
# generate_data_from_r.R
library('ravro')

# Built-in iris dataset
# Write out the data
iris_avro_path <- tempfile(fileext=".avro", tmpdir=getwd())
write.avro(iris,iris_avro_path,unflatten=TRUE)

# Inspect the Avro schema
str(avro_get_schema(mtavro_path))

# Importing flattened data
str(read.avro(iris_avro_path,flatten=TRUE))

# Importing unflattened data
str(read.avro(iris_avro_path,flatten=FALSE))
```



```
# read_data_from_r.rb
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
```


##Getting Avro Tools
You can get a copy of the latest stable Avro Tools jar file from the Avro Releases page. The actual file is in the java subdirectory of a given Avro release version. You can place it in your home directory to ensure it's in your PATH.

Here is a direct link to avro-tools-1.7.7.jar (12 MB).

**JSON to binary Avro**
```
$ java -jar ~/avro-tools-1.7.7.jar fromjson --schema-file items.avsc items.json > items.avro
```

**Binary Avro to JSON**
The same command will work on both uncompressed and compressed data.
```
$ java -jar ~/avro-tools-1.7.7.jar tojson items.avro > items.json
```

**Retrieve Avro schema from binary Avro**
The same command will work on both uncompressed and compressed data.
$ java -jar ~/avro-tools-1.7.7.jar getschema items.avro > items.avsc
