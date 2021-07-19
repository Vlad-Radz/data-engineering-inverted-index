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
    - Also no linters, `black`, `pre-commit`, `makefile` and other development tools that I usually use, were used in this project so far.
    - The code needs to be fine-tuned in terms of productivity - I didn't really leverage power of parallelization of `Spark` (e.g. usage of multiple nodes and partitioning to avoid shuffling).

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

### __Current implementation: distributed computing framework__

To calculate the inverted index, I decided to use distributed computation framework like `Spark` (actually its `Python` implementation - `pyspark`). Motivation behing this decision:
1. It scales: you can add new nodes to the cluster and partition your data, which would make sense in our case, since we are working with words, and they can be easily divided into groups by starting letters.
2. `Spark` seemlessly integrates with `AWS S3` as data source.

Algorithm:
- read the contents of files in a certain directory (done);
- partition data between diff. nodes (not done);
- replace each word with a unique ID. How this can be done: as I described in a diff. section above, it IDs can be positions of words in a sorted set. (not done);
- create separate tuple (in a `Spark` RDD) / row (in `SparkSQL`) / other data entity for each word (done);
- merge tuples / rows / other data entitities, where words are equal - `reduce by key` operation from functional programming (done).

### __Possible implementation: leverage bitmaps__
I thought of another possible implementation, which could leverage power of such data structure as bitmaps.

_What is a bitmap?_: A bitmap is an array of bits, that is, an array of the form: _[1, 0, 0, 1, 1]_. This data structure is very memory efficient and has a computational search complexity of O(1), and is often used in various search scenarios. For example, if we have users with a numeric ID and we want to store some binary data about the user (say, his willingness to subscribe to a mailing list), then a bitmap is an ideal candidate for implementation.

Algorithm:
- We could give numeric IDs to words in the same way that I described above: by adding words to a sorted set and getting their positions.
- Then we create a bitmap for each file from our object storage, and each word presenting in a file gets a `1` on its position
- `Redis` can be used to store the bitmaps. This article might be useful in the future: https://sudonull.com/post/97275-Fast-catalog-filter-for-online-stores-based-on-Redis-bitmaps

__Note__: _this solution was not implemented and tested - for now it's just a theoretical construct._

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

What can be improved:
- no logging right now
- no uniform formatting
- poor code organization - division into classes could be far better.

Design considerations for the future:
- facades for systems like Spark, Redis
- abstract factory pattern for boundles of EMR + S3 etc.

## Results:

This is the current output of the `pyspark` application:

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

- `flatten()` doesn't flatten a deeply nested list correctly. Example of a nested list after flattening: ```('accent', [['s3://pyspark-test-vlad/vocab.enron.txt', 's3://pyspark-test-vlad/vocab.kos.txt'], 's3://pyspark-test-vlad/vocab.nips.txt', 's3://pyspark-test-vlad/vocab.nytimes.txt', 's3://pyspark-test-vlad/vocab.pubmed.txt'])``` --> quick fix: repeat flatten operation for 3x times.

-----------------------------------------------------------------------

## Deployment

### __1st version: Terraform + AWS EMR__

I chose `Terraform` as IaaC technology. With its help I create infrastructure needed for setup of an `AWS EMR` cluster. All the `terraform` code was written by me, except 1 module (`iam`) - reference can be found in the respective `main.tf` file.

__Resources created by the `terraform` code:__
- `Amazon EMR` cluster, that `pyspark` applications can be submitted to.
- `IAM` roles needed for `Amazon EMR` permissions to AWS services and resources. Each cluster in `Amazon EMR` must have a service role and a role for the `Amazon EC2` instance profile.
- a default subnet, needed for creation of `Jupyter` notebooks.
- 3 `S3` buckets: for storage of source data (lists of words), logs and application scripts.
- `EC2` key pair, needed for SSH access to the cluster.

__How to run the `pyspark` app on the cluster created with `terraform`?__
- Due to reasons described below it is not possible to run `pyspark` applications on the created cluster. That's why the application should be deployed in a `Docker` container - check the "_2nd version: Docker_" section below.

__Why the cluster solution didn't work out?__
1. Integration efforts. Mechanisms of submission of `pyspark` apps are not straightforward, and due to time shortage I couldn't fix all the issues.
2. What app submission options do exist at all?
    - automatically submit the location of app script on `S3` via `spark-submit` CLI app and `step` mechanism of `Amazon EMR`
    - work in an interactive notebook (`Jupyter Notebook`). This solution is bad for the described task of indexing, and regular automated reindexing, but for a quick demo would be OK
    - SSH into the cluster and submit the code manually
3. Issues that I had:
    - Creating notebooks is not possible in `terraform` - only in the web console;
    - but also this is not so easy - you need to install `Jupyter Entreprise Gateway` first;
    - Bootstrapping action (download app script from `S3`) didn't succeed - probably because of denied access to `S3` bucket. Resources that might help: https://stackoverflow.com/questions/62983941/install-boto3-aws-emr-failed-attempting-to-download-bootstrap-action and https://forums.aws.amazon.com/thread.jspa?threadID=164769

__Note: you still can deploy the `terraform` code - it will create a working `AWS EMR` cluster and all the needed resources like IAM roles and buckets. What is not working, is possibility to submit `pyspark` apps, which makes the cluster practically useless.__

__How to deploy the `terraform` code?__
- In the `terraform\deployment\emr_based\variables.tfvars` file replace variables `aws_profile`, `aws_region` and `role_arn` with yours.
- Go to the correct directory: ```cd terraform\deployment\emr_based```
- initialize `terraform` there: ```terraform init```
- (optional) create a plan: ```terraform plan -out="../../tfplan" -var-file="variables.tfvars"```
- apply the code to your AWS account: ```terraform apply -var-file="variables.tfvars"```
- !!!!!!! Don't forget to destroy the deployed infrastructure - `Amazon EMR` is really expensive !!!!!!! ```terraform destroy -var-file="variables.tfvars"```
- If you have multi-factor authentication, then you can execute `terraform` commands by combining them with `aws-vault`. Example of the destroy command: ```aws-vault exec nc-account -- terraform destroy -var-file="variables.tfvars"```

### __2nd version: Docker__

This deployment option only needs `Docker` to be installed on your machine.

1. Build the container image: ```docker build -t pyspark --build-arg PYTHON_VERSION=3.8 --build-arg IMAGE=buster .```
2. Start the container ```docker run -it pyspark```
3. The `pyspark` application will start automatically, and you can see the output in your terminal. Note: adjust configuration of your terminal, so that you can see more line - the output is very long (tens of thousands of lines).

