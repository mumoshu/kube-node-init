#!/usr/bin/env bash

set -e

rm -rf packages/ || true
mkdir -p packages/
for v in 0.1.0 0.1.1 0.1.2 0.2.0 0.2.1; do
  git checkout kube-node-init-$v
  helm package -u charts/kube-node-init --destination packages
done
git checkout master
