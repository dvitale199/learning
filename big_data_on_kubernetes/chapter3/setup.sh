# deploy cluster locally
########################
kind create cluster

# check cluster info:
kubeclt cluster-info
########################
########################

# deploy gcp-based cluster
########################

PROJECT_ID=genotools

gcloud config set compute/zone us-central1-a
gcloud container clusters create studycluster --num-nodes=2

# save creds locally to kubernetes config file
gcloud container clusters get-credentials studycluster
# verify that you can connect
kubectl cluster-info

gcloud artifacts repositories create jokeapi-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="Repository for Joke API images"

gcloud auth configure-docker us-central1-docker.pkg.dev

# build docker
docker build --platform=linux/amd64 -t jokeapi:v1 .
docker tag jokeapi:v1 us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi:v1
docker push us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi:v1

# create namespace
kubectl create namespace jokeapi
# apply deployment
kubectl apply -f deployment_api.yaml -n jokeapi

# edit deployment if needed
kubectl edit deployment jokeapi -n jokeapi

# check deployment and pods are up
kubectl get deployments -n jokeapi
kubectl get pods -n jokeapi


##### DEBUGGING PLATFORM ISSUE #####
# test run pod to check image
kubectl run test-pull --image=us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi:v1 -n jokeapi
kubectl describe pod test-pull -n jokeapi
# debug pod
kubectl describe pod test-pull -n jokeapi
# inspect image - look at platform architecture - built on mac with --platform=linux/amd64 above
docker manifest inspect us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi:v1
# issue was that the image was built on mac without --platform=linux/amd64 above
# delete test pod:
kubectl delete pod test-pull -n jokeapi
# now re-run the pod with the correct image:
kubectl run test-pull --image=us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi:v1 -n jokeapi
kubectl get pod test-pull -n jokeapi
kubectl describe pod test-pull -n jokeapi
# clean up test pod
kubectl delete pod test-pull -n jokeapi
# restart deployment
kubectl delete pods -n jokeapi --selector=app=jokeapi
# verify deployment is running
kubectl get pods -n jokeapi
# check logs
kubectl logs -l app=jokeapi -n jokeapi
# check service
kubectl get service -n jokeapi
# IT WORKS!
##### END DEBUGGING PLATFORM ISSUE #####




# create loadbalancer
kubectl apply -f lb_api.yaml -n jokeapi

# use ingress to access the api via nginx ingress controller
kubectl create namespace ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/baremetal/deploy.yaml -n ingress-nginx

# now edit the service by changing the spec.type field to LoadBalancer
kubectl edit service ingress-nginx-controller -n ingress-nginx

# apply ingress
kubectl apply -f ingress.yaml -n jokeapi


# other important comands:
# get the service
kubectl get services -n jokeapi
# switch to that namespace
kubectl config set-context --current --namespace=jokeapi

# get contexts
kubectl config get-contexts
kubectl config current-context


###### COMMANDS FOR CHECKING CLUSTER STATUS ######
# cluster info
kubectl cluster-info
# get full cluster info dump
kubectl cluster-info dump

# check services
kubectl get services -n jokeapi
# describe service
kubectl describe service -n jokeapi

# get nodes
kubectl get nodes
# describe node
kubectl describe node -n jokeapi

# get pods
kubectl get pods -n jokeapi
# describe pod
kubectl describe pod -n jokeapi

# get cluster-wide resources
kubectl get all --all-namespaces

# get all resources in jokeapi namespace
kubectl get all -n jokeapi




###### RUNING JOBS ######
docker build --platform=linux/amd64 -f Dockerfile_job -t jokeapi-job:v1 .
docker tag jokeapi-job:v1 us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi-job:v1
docker push us-central1-docker.pkg.dev/genotools/jokeapi-repo/jokeapi-job:v1

kubectl create namespace datajobs
kubectl apply -f job.yaml -n datajobs

kubectl get jobs -n datajobs
