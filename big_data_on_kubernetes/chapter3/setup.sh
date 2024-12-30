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

# save creds locallyy to kubernetes config file
gcloud container clusters get-credentials studycluster
# verify that you can connect
kubectl cluster-info