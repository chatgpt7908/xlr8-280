#!/bin/bash

echo "🛠️ Creating project 'lerna'..."
oc new-project lerna >/dev/null

echo "🚀 Deploying hydra app with hello-openshift image..."
cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hydra
  namespace: lerna
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hydra
  template:
    metadata:
      labels:
        app: hydra
    spec:
      containers:
      - name: hydra
        image: quay.io/redhattraining/hello-openshift
        ports:
        - containerPort: 8080
EOF

echo "✅ hydra app deployed with 1 replica in 'lerna' namespace"

