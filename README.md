

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

How to connect to S3 from local? So that it also works from Docker and EMR notebook? --> boto not needed. Bucket needs to made public

## Known bugs

- nested list not always flattened: ```('accent', [['s3://pyspark-test-vlad/vocab.enron.txt', 's3://pyspark-test-vlad/vocab.kos.txt'], 's3://pyspark-test-vlad/vocab.nips.txt', 's3://pyspark-test-vlad/vocab.nytimes.txt', 's3://pyspark-test-vlad/vocab.pubmed.txt'])```

# Deployment

## 1st version: Terraform + AWS EMR

Wrote by myself except 1 module (IAM)

Works, but can't submit pyspark job, and didn't want to waste time - shouldn't be perfect.
Also create notebooks (I know that Jupyter Notebook is bad for the described task of indexing, and regular automated reindexing, but for quick demo would be OK) is not possible in Terraform.

What does terraform create?

- ```cd terraform\deployment\computation```
- ```terraform plan -out="../../tfplan" -var-file="variables.tfvars"```
- ```terraform apply -var-file="variables.tfvars"```
- ```aws-vault exec nc-account -- terraform destroy -var-file="variables.tfvars"```

## 2nd version: Docker

# Testing strategies

Integration:
- minio instead of s3
- moto

# Not done

- scheduling + reindexing
- not a Lambda function
- ID instead of words
- didn't rename files


# Next steps:
1. write code for connecting to S3
2. add context and session for Spark
3. Test it on EMR
4. Write Dockerfile, mount directory, test if works
    4.1. If not - maybe because of networking. Debug
5. If doesn't work for more than 1 hour: moto. I think, that should be possible. Potential complexity: use moto from a Docker container
6. If Docker doesn't work, then manual creation of notebooks -> deploy EMR etc. with Terraform and test if you can create notebooks in the console
7. Document all of this
8. Document Redis, hashmap, search, ordered sets; also describe that sets etc. could also be used in this strategy
9. Refactor code
10. Write a couple of cases with `Pytest`