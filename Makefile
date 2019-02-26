TAG ?= 0.1.0

dev: TAG=dev-$(shell md5 -q Dockerfile)
dev:
	docker build -t mumoshu/kube-node-init:$(TAG) .
	bash -c 'cd charts/kube-node-init && helm dependency build'
	helm tiller run tiller-system -- helm template --set image.tag=$(TAG) --set script=echo charts/kube-node-init
	helm tiller run tiller-system -- helm upgrade --debug --install --force --set image.tag=$(TAG) --set script=echo node-init-dev charts/kube-node-init

build:
	docker build -t mumoshu/kube-node-init:$(TAG) .

push:
	docker push mumoshu/kube-node-init:$(TAG)
