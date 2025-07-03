#!/bin/bash

echo "[+] Step 1: SSH into utility -> master01 and pull image..."

ssh lab@utility << 'EOF_UTILITY'

  echo "[+] Connected to utility."

  ssh -i .ssh/lab_rsa core@master01 << 'EOF_MASTER'

    echo "[+] Logging into quay.io..."
    podman login quay.io -u ysachin -p hitachi@321

    echo "[+] Pulling image quay.io/ysachin/ocp-exam:latest..."
    podman pull quay.io/ysachin/ocp-exam:latest

    echo "[+] Done pulling image. Exiting master01."
    exit

EOF_MASTER

  echo "[+] Exiting utility."
  exit

EOF_UTILITY

echo "[+] Step 2: Creating /home/student/q14 and writing YAML files..."

mkdir -p /home/student/q14
#Creating Project

oc  project apples
# Deployment
cat << 'EOF_DEPLOY' > /home/student/q14/oranges-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oranges
  labels:
    app: oranges
spec:
  replicas: 1
  selector:
    matchLabels:
      app: oranges
  template:
    metadata:
      labels:
        app: oranges
    spec:
      containers:
        - name: nginx
          image: quay.io/ysachin/ocp-exam
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
EOF_DEPLOY

# Service with non-matching label
cat << 'EOF_SVC' > /home/student/q14/oranges-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: oranges-service
spec:
  selector:
    app: mango  # <-- Intentional mismatch to avoid endpoints
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF_SVC

# Route with custom host
cat << 'EOF_ROUTE' > /home/student/q14/oranges-route.yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: oranges-route
spec:
  host: oranges.apps.ocp4.example.com
  to:
    kind: Service
    name: oranges-service
  port:
    targetPort: 80
EOF_ROUTE

echo "[+] Step 3: Applying Deployment, Service, and Route..."

cd /home/student/q14
oc apply -f oranges-deploy.yaml
oc apply -f oranges-service.yaml
oc apply -f oranges-route.yaml

echo "[+] ✅ Done! Resources created."
echo "    - Deployment: oranges"
echo "    - Service (no endpoints): oranges-service"
echo "    - Route: http://oranges.apps.ocp4.example.com"

