

# Dependencies management
```conda create -n dataeng python=3.8```
```conda activate dataeng```
```pip install pyspark```
```conda list``` - to check

```conda install --file requirements.txt```
```python ./app/app.py```

# Code design

facades for systems like Spark, Redis + hashmap

in ABC there is always storage and transformation logic

Strategy pattern
- https://refactoring.guru/design-patterns/strategy
- https://stackoverflow.com/questions/616796/what-is-the-difference-between-factory-and-strategy-patterns

How to connect to S3 from local? So that it also works from Docker and EMR notebook?

## Known bugs

- nested list not always flattened: ```('accent', [['s3://pyspark-test-vlad/vocab.enron.txt', 's3://pyspark-test-vlad/vocab.kos.txt'], 's3://pyspark-test-vlad/vocab.nips.txt', 's3://pyspark-test-vlad/vocab.nytimes.txt', 's3://pyspark-test-vlad/vocab.pubmed.txt'])```

# Deployment

## 1st version: Terraform + AWS EMR

Wrote by myself except 1 module (IAM)

Works, but can't submit pyspark job, and didn't want to waste time - shouldn't be perfect

What does terraform create?

- ```terraform plan -out="../../tfplan" -var-file="variables.tfvars"```
- ```terraform apply -var-file="variables.tfvars"```
- ```aws-vault exec nc-account -- terraform destroy -var-file="variables.tfvars"```

## 2nd version: Docker

# Testing strategies

minio instead of s3

# Not done

- scheduling + reindexing
- not a Lambda function
- ID instead of words
- didn't rename files