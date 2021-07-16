# from pyspark.sql import functions as F
from pyspark.sql.functions import col, substring, split

input_bucket = 's3://pyspark-test-vlad/'
input_path = '/*.txt'
log_txt = sc.wholeTextFiles(input_bucket)
print("HELLO")
one_log_txt = log_txt.mapValues(lambda k: k.split("\\t"))
log_df = one_log_txt.toDF(['source', 'words'])
# log_df.select(col("source")).show()
# log_df.select(substring(log_df.source, -20, 20).alias('s')).collect()
# log_df.select(col("source")).split("/").collect()
split_col = split(log_df['source'], '/')
log_df = log_df.withColumn('filename', split_col.getItem(3))
log_df.select('filename').collect()
print("BYE BYE")
# log_df.show()

# df = spark.read(input_bucket + input_path)
# df.show()
sc.stop()