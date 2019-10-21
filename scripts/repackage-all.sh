#!/usr/bin/env bash

set -e

rm -rf packages/ || true
mkdir -p packages/

# 0.1.0 is unable to be built on some reason. just skip it assuming one one's using it today...
for v in 0.1.1 0.1.2 0.2.0 0.2.1; do
  git checkout kube-node-init-$v
  pushd charts/kube-node-init
  CHART=.
  BASE_DIR=../..
  helm dep build ${CHART}
  cat ${CHART}/requirements.*
  ls -lah ${CHART}/charts
  helm package ${CHART} --destination ${BASE_DIR}/packages
  popd
done

git checkout master
