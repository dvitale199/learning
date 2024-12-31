# deploy cluster locally
########################
kind create cluster

# check cluster info:
kubeclt cluster-info
########################
########################

# deploy gcp-based cluster
########################
gcloud config set compute/zone us-central1-a1
gcloud container clusters create studycluster --num-nodes=2

# save creds locally to kubernetes config file
gcloud container clusters get-credentials studycluster
# verify that you can connect
kubectl cluster-info

# build docker
docker build -t dv199/jokeapi:v1 .
docker push dv199/jokeapi:v1

# create deployment using deployment_api.yaml
kubectl create namespace jokeapi
kubectl apply -f deployment_api.yaml -n jokeapi

# check deployment and pods are up
kubectl get deployments -n jokeapi
kubectl get pods -n jokeapi

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
kubectl get services -n jokeapi
# switch to that namespace
kubectl config set-context --current --namespace=jokeapi

# get contexts
kubectl config get-contexts
kubectl config current-context