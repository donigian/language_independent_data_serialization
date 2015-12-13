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
