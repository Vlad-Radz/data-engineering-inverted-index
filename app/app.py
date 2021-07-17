
from pyspark.sql import functions as F

# TODO: SparkSession and SparkContext
# spark = SparkSession.builder.appName('inverted_index').getOrCreate()

input_bucket = 's3://pyspark-test-vlad/'
input_path = '/*.txt'

# TODO: partition by letter - less shuffling (right?)
# TODO: no need to parallelize - or?

log_txt = sc.wholeTextFiles(input_bucket)
one_log_txt = log_txt.mapValues(lambda k: k.split("\n"))
#log_df = one_log_txt.toDF(['source', 'words'])
#split_col = F.split(log_df['source'], '/')
#log_df = log_df.withColumn('filename', split_col.getItem(3))
#log_df.select('filename').collect()

# exploded_df = log_df.withColumn("words", F.explode("words")).select(['filename', 'words'])
one_log_txt = one_log_txt.flatMap(lambda x: [(x[0], w) for w in x[1]])
one_log_txt = one_log_txt.map(lambda x: (x[1], x[0]))
exploded_df = one_log_txt.reduceByKey(lambda a,b: [a, b])

def flatten(_2d_list):
    flat_list = []
    # Iterate through the outer list
    if type(_2d_list) is list:
        for element in _2d_list:
            if type(element) is list:
                # If the element is of type list, iterate through the sublist
                for item in element:
                    flat_list.append(item)
            else:
                flat_list.append(element)
    else:
        flat_list.append(_2d_list)
    return flat_list

exploded_df = exploded_df.map(lambda x: (x[0], flatten(x[1])))
exploded_df = exploded_df.map(lambda x: (x[0], flatten(x[1])))  # dirty hack
exploded_df = exploded_df.map(lambda x: (x[0], flatten(x[1])))

exploded_df = exploded_df.map(lambda x: (x[0], [n.split("/")[3] for n in x[1]]))

for x in exploded_df.collect():
    print(x)