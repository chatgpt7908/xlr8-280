#!/bin/bash

# Create 'atlas' project and deploy 'mercury' pod
oc new-project atlas

oc run mercury \
  --image=quay.io/redhattraining/hello-world-nginx:v1.0 \
  --restart=Always \
  --labels="app=mercury" \
  --port=8080 \
  -n atlas

oc expose pod mercury --port=8080 -n atlas

# Create 'bluewills' project and deploy 'rocky' pod
oc new-project bluewills

oc run rocky \
  --image=quay.io/redhattraining/hello-world-nginx:v1.0 \
  --restart=Always \
  --labels="app=rocky" \
  --port=8080 \
  -n bluewills

