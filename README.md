# Knative Example on microk8s 

This is a small template on how knative functions can be easily deployed on k8s and automate the deployment process.

## Installing knative on microk8s / k8s distribution


### For Microk8s enable addons 

    microk8s enable helm3 istio dashboard metallb dns storage
    #(Give avaliable IP range eg 192.168.1.30 - 192.168.1.40)
    sudo snap alias microk8s.kubectl kubectl
    sudo snap alias microk8s.helm3 helm

### For other k8s distibutions

Follow the knative [documentation](https://knative.dev/docs/admin/install/installing-istio/) on installing istio and other prerequisites.  

### Installing knative serving and eventing components 

Install Serving Components 

    kubectl apply -f https://github.com/knative/serving/releases/download/v0.24.0/serving-crds.yaml
    kubectl apply -f https://github.com/knative/serving/releases/download/v0.24.0/serving-core.yaml
    kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.24.0/net-istio.yaml
    kubectl apply -f https://github.com/knative/serving/releases/download/v0.24.0/serving-default-domain.yaml

Install Eventing Components  

    kubectl apply -f https://github.com/knative/eventing/releases/download/v0.24.0/eventing-crds.yaml
    kubectl apply -f https://github.com/knative/eventing/releases/download/v0.24.0/eventing-core.yaml
    kubectl apply -f https://github.com/knative/eventing/releases/download/v0.24.0/in-memory-channel.yaml
    kubectl apply -f https://github.com/knative/eventing/releases/download/v0.24.0/mt-channel-broker.yaml


## Build and deploy functions on k8s 


To Build the functions run below command. This will build the docker images , and copy them over to microk8s local.

    make build_microk8s 

To deploy the functions run 

    make deploy 

To get access URL's run below command 

    kubectl get ksvc

Example outout 

    NAME                     URL                                                       LATESTCREATED                  LATESTREADY              READY     REASON
    hello-private-function   http://hello-private-function.default.svc.cluster.local   hello-private-function-00001                            Unknown   RevisionMissing
    hello-knative            http://hello-knative.default.192.168.1.40.sslip.io        hello-knative-00001            hello-knative-00001      True      
    hello-world              http://hello-world.default.192.168.1.40.sslip.io          hello-world-00001              hello-world-00001        Unknown   Uninitialized
    hello-kubernetes         http://hello-kubernetes.default.192.168.1.40.sslip.io     hello-kubernetes-00001         hello-kubernetes-00001   Unknown   IngressNotConfigured
