
from pyspark.sql import functions as F
from pyspark.context import SparkContext


def flatten(a_list):
    # TODO: refactor function - is ugly
    flat_list = []
    # Iterate through the outer list
    if type(a_list) is list:
        for element in a_list:
            if type(element) is list:
                # If the element is of type list, iterate through the sublist
                for item in element:
                    flat_list.append(item)
            else:
                flat_list.append(element)
    else:
        flat_list.append(a_list)
    return flat_list

sc = SparkContext('local', 'inverted_index')

# TODO: connect to AWS from Spark, so that this script can work not only from a Notebook in AWS EMR, but also from Docker or locally:
# https://stackoverflow.com/questions/29443911/locally-reading-s3-files-through-spark-or-better-pyspark

# input_bucket = 's3://pyspark-test-vlad/'
input_bucket = 'file:///words_index/'
input_path = '/*.txt'

# TODO: partition by letter - less shuffling (right?)
# TODO: no need to parallelize - or?

rdd_files_contents = sc.wholeTextFiles(input_bucket)

rdd_words = rdd_files_contents.\
                mapValues(lambda k: k.split("\n")).\
                flatMap(lambda x: [(x[0], w) for w in x[1]]).\
                map(lambda x: (x[1], x[0])).\
                reduceByKey(lambda a,b: [a, b]).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], flatten(x[1]))).\
                map(lambda x: (x[0], [n.split("/")[2] for n in x[1]]))

# TODO: dirty hack: flattening needs to be done 3x - function needs to be adjusted

for i, x in enumerate(rdd_words.collect()):
    print(x)
    #if i == 10:
    #    break
