## Make file For building applications and pushing containers to test and prod
## Global vars

#FUNCS = test-knative test-job job-process-file-sources job-subset-selection
FUNCS = hello-knative hello-kubernetes hello-private-function hello-world
DOCKER_HUB_DOMAIN = hwf_platform
VERSION = 1.0


.PHONY: help
help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build
build: ## Builds docker images for knative functions
	@for dir in $(FUNCS); do \
  		echo "*************************************" ; \
  		echo Building Docker image for $$dir ; \
  		docker build ./$$dir -t $(DOCKER_HUB_DOMAIN)/$$dir:$(VERSION) ;\
	done


.PHONY: copy_to_microk8s
copy_to_microk8s: ## Copies built containers to microk8s internal docker registry
	@for dir in $(FUNCS); do \
  		echo "*************************************" ; \
  		echo Copying $$dir ; \
  		docker save dev.local/$$dir:local > $$dir.tar ;\
  		microk8s ctr image import $$dir.tar ;\
  		rm $$dir.tar ;\
	done


.PHONY: build_microk8s
build_microk8s: ## Build docker containers and push them to microk8s
	make DOCKER_HUB_DOMAIN=dev.local VERSION=local build
	make copy_to_microk8s


.PHONY: deploy
deploy: ## Deploys the containers to k8s instance
	@for dir in $(FUNCS); do \
  		echo "*************************************" ; \
  		echo Deploying $$dir ; \
		kubectl apply -f ./$$dir/service.yaml ;\
	done


.PHONY: delete
delete: ## Deletes deployed services
	@for dir in $(FUNCS); do \
  		echo "*************************************" ; \
  		echo Deploying $$dir ; \
		kubectl delete -f ./$$dir/service.yaml ;\
	done


.PHONY: rebuild
rebuild: ## Rebuilds the deployment by deleting and recreating the services
	make delete deploy