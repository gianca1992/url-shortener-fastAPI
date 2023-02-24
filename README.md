# url-shortener-fastAPI

This pyhon app uses FastAPI, Uvicorn as web Server and SQL Alchemy as DB to implement a local url shortener. 

The python code was grabbed from [here](https://github.com/realpython/materials/tree/master/fastapi-url-shortener/source_code_final/shortener_app).
You will find a detailed description of the code and API [here](https://realpython.com/build-a-python-url-shortener-with-fastapi/).  

I have written a Dockerfile and made it available in this repo along with the python code, with a main.tf file and with a pull-run-shortener.sh script. 
I will show a step-by step guide to dockerise the app and to deploy it on AWS using Terraform. 

When the main.tf file is invoked, some AWS infrastructure is automatically deployed, the pull-run-shortener.sh run to install docker, to pull the image from the docker registry and to create a container where the url shortener app will be running on the provisioned EC2 instance.  

As prerequisites, you will need to [install Docker](https://docs.docker.com/engine/install/) and [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) in your local machine, you need to create an [AWS free tier account](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all), a [docker hub account](https://hub.docker.com/), an [AWS programmatic access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) and a [key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) for Terraform to be able to interact with the EC2 instance. 
 


###  A 
Clone the repo, cd to the root dir where Dockerfile resides, edit the Dockerfile and the pull-run-shortener.sh and when you are ready

### B 
Build the image locally:

```
docker build -t url-shortener-giancarlo . 
```

Run a container from it to test it: 

```
docker run -p 8000:8000 url-shortener-giancarlo
```

You should see something similar to:

```
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

run ```curl localhost:8000``` to see a test hello message, 

```
"Hello from the URL shortener FastAPI python app"
```

### C 
Create a repository from your dockerhub account, name it for example "repo-for-shortener"

Tag the image and then push it to your dockerhub repository:

```
docker tag url-shortener-giancarlo:latest your-dockerhub-username/repo-for-shortener

docker push your-dockerhub-username/repo-for-shortener
```

### D 
Set up a CLI programmatic access key from AWS, create a key pair from AWS, name it key_pair.pem. This will be used by terraform to deploy the app on an EC2 instance by leveraging the shell script

### E
Launch the terrafrom commands locally by replacing your programmatic access credentials: 

```
terraform init 
terraform plan -var 'aws_access_key=XXXXXX' -var 'aws_secret_key=XXXXXXX' 
terraform apply -var 'aws_access_key=XXXXXX' -var 'aws_secret_key=XXXXXXX' 
```

### F
You can ssh into the ec2 instance to test the application: 

```
ssh -i ~/Path/to/key/key_pair.pem ec2-user@ec2-XXX-XXX-XXX.eu-west-2.compute.amazonaws.com
```

You can see if the docker image is running with: 

```
sudo docker ps
CONTAINER ID   IMAGE                                 COMMAND                  CREATED         STATUS         PORTS                                       NAMES
XXXXXXX   your-dockerhub-username/repo-for-shortener:latest   "/bin/sh -c 'python …"   2 minutes ago   Up 2 minutes   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp   modest_sinoussi


curl localhost:8000
"Hello from the URL shortener FastAPI python app"
```


### G  
Send a POST request via CURL populating the target_url with the url you want to shorten, for example let's use https://www.youtube.com/watch?v=0yWAtQ6wYNM  
```
[ec2-user@ip-172-31-27-242 ~]$ curl -X 'POST'   'http://0.0.0.0:8000/url'   -H 'accept: application/json'   -H 'Content-Type: application/json'   -d '{
  "target_url": "https://www.youtube.com/watch?v=0yWAtQ6wYNM"}'
 ```
 
 You will get in response the shortened link, for example in my case http://localhost:8000/DI9LL

```
 {"target_url":"https://www.youtube.com/watch?v=0yWAtQ6wYNM","is_active":true,"clicks":0,"url":"http://localhost:8000/DI9LL","admin_url":"http://localhost:8000/admin/DI9LL_B01AFMEA"}
 ```

### H 
You can test them with ```curl -L http://localhost:8000/DI9LL``` and ```curl https://www.youtube.com/watch?v=0yWAtQ6wYNM```



