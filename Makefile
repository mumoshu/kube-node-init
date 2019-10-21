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

repackage-all:
	scripts/repackage-all.sh || git checkout master

DIR ?= packages-work
REPO ?= kube-node-init
CHART ?= kube-node-init

# Creates a packages-up/prometheus-process-exporter-x.y.z.tgz and a prometheus-process-exporter-x.y.z tag and then creates a corresponding github release
upload:
	mkdir -p $(DIR)
	rm -rf $(DIR)/*
	helm package charts/$(CHART) --destination $(DIR)
	cr upload -o mumoshu -t $(GITHUB_TOKEN) -r $(REPO) -p $(DIR)
	cp $(DIR)/* packages/

index:
	cr index -p packages -r $(CHART) -i docs/index.yaml -o mumoshu -c https://github.com/mumoshu/$(REPO)
	git add docs/index.yaml
