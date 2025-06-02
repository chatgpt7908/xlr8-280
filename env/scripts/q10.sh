#!/bin/bash

echo "🚀 Creating project 'gru'..."
oc new-project gru >/dev/null

echo "🧱 Deploying 'scala' app with minimal config (no CPU, no HPA)..."
cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scala
  namespace: gru
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scala
  template:
    metadata:
      labels:
        app: scala
    spec:
      containers:
      - name: scala
        image: quay.io/redhattraining/hello-openshift
        ports:
        - containerPort: 8080
EOF

echo "✅ Environment ready: 'gru' namespace and 'scala' app deployed"

