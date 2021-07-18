# What is this project about

This project is about applying various concepts from data engineering world. The task sounds like follows:

__Prerequisites__:
1. Large collection of files in `AWS S3` or `GCP` object storage.
2. Each file has a set of words in it.
3. Each file is named after its order in the large collection, e.g. `2.txt`, or `3.txt`.

__Goals__:
1. An inverted index should be build:
    - Create a dictionary that matches each word from all of the files to a unique ID.
    - Create a dictionary that matches each file to a unique ID (should be the name of the file)
    - Bring words and origin files together. E.g.: `{127: [1, 6, 938]}`
    - Sort those pairs by word ID and file ID.
    - Final step: inverted index, that gives for each word the file names of where it appears.
2. The solution should scale and perform well on a large set of files.
3. Solution should be deployed in a public cloud.

__Additional considerations__:
1. Rebuild of the index should be triggered on regular basis (let's say, every night). Which means, new data should come into the object storage, and we need a mechanism to recognise the delta.
2. Solution should be ideally serverless.

# Solution

## Technology decisions
I chose `PySpark` for computation of inverted index, because the solution should scale well, and a distributed computation framework is an ideal candidate for such a task.

Since the solution should ideally be serverless, I tried to deploy my solution in an `AWS EMR` ("Elastic Map Reduce") cluster, which is a managed Hadoop / Spark environment, but I had problems, which I wull described in a diff. section below.

`Terraform` was chosen as infra-as-a-code solution, because of some familiarity and popularity in the community.

## My focus, and what I had to ignore (no IDs instead of words, no testing and more)

The task sounds pretty simple, but if you want to do in short time, you need to concentrate on some things and compromise some others.

My compromises (reason for all of them - __time shortage__):
- Severe:
    - I didn't create dictionary, which would map words to IDs. But __how would I implement it__: I would use a sorted set as data structure, which words are appended to; since a set can't have duplicates, the words which were already indexed at least once, will keep their IDs, and thanks to sorting new words will get correct positional IDs. The set can be stored in an object storage like `S3` or in the `Redis` database. 
    - I left the original file names, and didn't rename them into ID-like names.
    - The result is not stored anywhere - is just an output in the console. You can also see a snippet in this `README` file (below).
- Nice to have:
    - Scheduling and reindexing is missing
    - no automated tests written. If I would have tested my solution, I would have done it with `pytest` for unit and integration tests. `moto` could be used for mocking `AWS` services. `pytest` and `moto` integrate seemlessly. Also `minio` could be used as a local S3-API-compatible object storage for integration testing.

What did I focus on:
- scalability of solution --> `PySpark` as technology of choice
- good documentation and description of choices --> `README.md` file with detailed description
- clean setup of infrastructure --> working `terraform` code base
- well structured and designed code --> `Strategy` pattern, dependency injection and other patterns
- Real-world data --> I found files, which are really used in the research (taken from here: https://archive.ics.uci.edu/ml/datasets/bag+of+words):
    - Enron Emails (`vocab.enron.txt`)
    - NIPS full papers (`vocab.nips.txt`)
    - NYTimes news articles (`vocab.nytimes.txt`)
    - dailykos.com blog entries (`vocab.kos.txt`)

## Overall logic of the solution

### Current implementation: distributed computing framework

### Possible implementation: leverage bitmaps

-----------------------------------------------------------------------

## Dependencies management
Right now the dependencies management is not needed, because the only dependecy of Python used is `pyspark`. In the future I would use `miniconda` with the following commands:
- To create a virtual environment: ```conda create -n dataeng python=3.8```
- Activate the virtual environment we created in the last step```conda activate dataeng```
- Install needed dependencies in the activated virtual environment:
    - Option 1: ```pip install pyspark```
    - Option 2: ```conda install --file requirements.txt```
- Check the installations: ```conda list```.

## Code design

facades for systems like Spark, Redis + bitmaps

in ABC there is always storage and transformation logic

Strategy pattern
- https://refactoring.guru/design-patterns/strategy
- https://stackoverflow.com/questions/616796/what-is-the-difference-between-factory-and-strategy-patterns

How to connect to S3 from local? So that it also works from Docker and EMR notebook? --> boto not needed. Bucket needs to made public

## Results:

```
('eyebrow', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('eyed', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('eyedrop', ['vocab.nytimes.txt'])
('eyeful', ['vocab.nytimes.txt'])
('eyeglass', ['vocab.nytimes.txt'])
('eyeglasses', ['vocab.nytimes.txt'])
('eyeing', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('eyelash', ['vocab.nytimes.txt'])
('eyelashes', ['vocab.nytimes.txt'])
('eyelet', ['vocab.nytimes.txt'])
('eyelid', ['vocab.nytimes.txt'])
('eyeliner', ['vocab.nytimes.txt'])
('eyewear', ['vocab.nytimes.txt'])
('eyewitness', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('eyewitnesses', ['vocab.nytimes.txt'])
('eying', ['vocab.nytimes.txt'])
('eyre', ['vocab.nytimes.txt'])
('f22', ['vocab.nytimes.txt'])
('fab', ['vocab.nytimes.txt'])
('fable', ['vocab.nytimes.txt'])
('fabricated', ['vocab.nytimes.txt', 'vocab.nips.txt'])
('fabricating', ['vocab.nytimes.txt'])
('fabrication', ['vocab.nytimes.txt', 'vocab.enron.txt', 'vocab.nips.txt'])
('fabricator', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('fabulous', ['vocab.nytimes.txt', 'vocab.enron.txt'])
('fabulously', ['vocab.nytimes.txt'])
('fabulousness', ['vocab.nytimes.txt'])
('facade', ['vocab.nytimes.txt'])
('facetiously', ['vocab.nytimes.txt'])
('facial', ['vocab.nytimes.txt', 'vocab.enron.txt', 'vocab.nips.txt'])
```

## Known bugs

- nested list not always flattened: ```('accent', [['s3://pyspark-test-vlad/vocab.enron.txt', 's3://pyspark-test-vlad/vocab.kos.txt'], 's3://pyspark-test-vlad/vocab.nips.txt', 's3://pyspark-test-vlad/vocab.nytimes.txt', 's3://pyspark-test-vlad/vocab.pubmed.txt'])``` --> dirty hack: repeat flatten operation for 3x times.

## Deployment

### 1st version: Terraform + AWS EMR

Wrote by myself except 1 module (IAM)

Cluster works, but:
1. can't submit pyspark job, and didn't want to waste time - shouldn't be perfect.
2. Also create notebooks (I know that Jupyter Notebook is bad for the described task of indexing, and regular automated reindexing, but for quick demo would be OK) is not possible in Terraform.
3. Jupyter Entreprise Gateway should be there to create notebooks manually
4. Bootstrapping can't start:
- https://stackoverflow.com/questions/62983941/install-boto3-aws-emr-failed-attempting-to-download-bootstrap-action
- https://forums.aws.amazon.com/thread.jspa?threadID=164769

What does terraform create?

- ```cd terraform\deployment\emr_based```
- ```terraform plan -out="../../tfplan" -var-file="variables.tfvars"```
- ```terraform apply -var-file="variables.tfvars"```
- ```aws-vault exec nc-account -- terraform destroy -var-file="variables.tfvars"```

variables.tfvars - replace vars

### 2nd version: Docker

- ```docker build -t pyspark --build-arg PYTHON_VERSION=3.8 --build-arg IMAGE=buster .```
- ```docker run -it pyspark```

