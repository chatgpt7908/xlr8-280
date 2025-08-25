#!/bin/bash

PROJECT="path-finder"
DEPLOYMENT_YAML="voyager-deployment.yaml"
SERVICE_YAML="voyager-service.yaml"
ROUTE_YAML="voyager-route.yaml"
NODE_LABEL_KEY="Tony"
NODE_LABEL_VALUE="Starc"

echo "Creating project: $PROJECT"
oc new-project $PROJECT || echo "Project already exists"

# Node pe label lagao
NODE_NAME=$(oc get nodes -l node-role.kubernetes.io/worker= -o jsonpath='{.items[0].metadata.name}')
echo "Labeling node $NODE_NAME with $NODE_LABEL_KEY=$NODE_LABEL_VALUE"
oc label node $NODE_NAME $NODE_LABEL_KEY=$NODE_LABEL_VALUE --overwrite

# Deployment YAML create karo
cat > $DEPLOYMENT_YAML <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: voyager
  namespace: $PROJECT
spec:
  replicas: 1
  selector:
    matchLabels:
      app: voyager
  template:
    metadata:
      labels:
        app: voyager
    spec:
      containers:
      - name: voyager
        image: quay.io/redhattraining/hello-world-nginx:v1.0
        ports:
        - containerPort: 80
      nodeSelector:
        trek: trek   # <-- Wrong nodeSelector for exam scenario
EOF

# Service YAML create karo
cat > $SERVICE_YAML <<EOF
apiVersion: v1
kind: Service
metadata:
  name: voyager
  namespace: $PROJECT
spec:
  selector:
    app: voyager
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOF

# Route YAML create karo
cat > $ROUTE_YAML <<EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: voyager
  namespace: $PROJECT
spec:
  to:
    kind: Service
    name: voyager
  port:
    targetPort: 8080
EOF

echo "Applying Deployment, Service and Route manifests..."
oc apply -f $DEPLOYMENT_YAML
oc apply -f $SERVICE_YAML
oc apply -f $ROUTE_YAML

echo "Wait 10 seconds for pod creation attempt with wrong nodeSelector..."
sleep 10

echo "Check pod status (expect Pending pods due to wrong nodeSelector):"
oc get pods -n $PROJECT

echo "Check service and route:"
oc get svc,route -n $PROJECT

