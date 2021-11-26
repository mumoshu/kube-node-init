IMAGE_REPO := 057575985710.dkr.ecr.ap-northeast-1.amazonaws.com
IMAGE_NAME := clusterops/kube-node-init
IMAGE_TAG ?= dev
IMAGE_URL := ${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

.PHONY: build.docker
build.docker:
	DOCKER_BUILDKIT=0 docker build \
		-t ${IMAGE_NAME}:${IMAGE_TAG} \
		.

.PHONY: login
login:
	@ aws ecr get-login-password --region ap-northeast-1 \
		| docker login --username AWS --password-stdin ${IMAGE_REPO}

.PHONY: push
push: login build.docker
	@docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_URL}
	@docker push ${IMAGE_URL}
