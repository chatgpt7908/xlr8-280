#!/bin/bash

# ======================
# Step 1: Create mercury namespace with database
# ======================
echo "Creating mercury namespace..."
oc new-project mercury

echo "Deploying MySQL database pod..."
oc new-app registry.ocp4.example.com:8443/rhel9/mysql-80 \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=dbuser \
  -e MYSQL_PASSWORD=password123 \
  -e MYSQL_ROOT_PASSWORD=rootpass123 \
  --name=database \
  -n mercury

echo "Exposing database service on port 3306..."
oc expose deployment database --port=3306 -n mercury

# ======================
# Step 2: Apply deny-all NetworkPolicy (Ingress & Egress)
# ======================
echo "Applying deny-all NetworkPolicy to mercury..."
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-traffic
  namespace: mercury
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# ======================
# Step 3: Create sun namespace with service account + anyuid SCC
# ======================
echo "Creating sun namespace..."
oc new-project sun

echo "Creating service account webapp-sa..."
oc create serviceaccount webapp-sa -n sun

echo "Granting anyuid SCC to webapp-sa..."
oc adm policy add-scc-to-user anyuid -z webapp-sa -n sun

# ======================
# Step 4: Deploy web application in sun
# ======================
echo "Deploying PHP webapp in sun..."
cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: sun
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      serviceAccountName: webapp-sa
      containers:
      - name: webapp
        image: quay.io/ysachin/ex280/php:7.4-apache
        ports:
        - containerPort: 80
        env:
        - name: MYSQL_HOST
          value: "database.mercury.svc.cluster.local"
        - name: MYSQL_USER
          value: "dbuser"
        - name: MYSQL_PWD
          value: "password123"
        - name: MYSQL_DATABASE
          value: "mydb"
        command: ["/bin/bash"]
        args:
        - -c
        - |
          apt-get update \
          && apt-get install -y default-mysql-client \
          && while true; do
               echo "[\$(date)] Attempting database connection..."
               mysql -h \$MYSQL_HOST -u \$MYSQL_USER \$MYSQL_DATABASE \
                 -e 'SELECT "Connection successful!" as status;' 2>&1 \
               && echo "[\$(date)] Connection successful!" \
               || echo "[\$(date)] Connection failed - Network policy blocking!"
               sleep 15
             done
EOF

echo "Exposing webapp service on port 80..."
oc expose deployment webapp --port=80 -n sun

# ======================
# Setup complete
# ======================
echo
echo "=== Verification ==="
echo "1. Database pods & service:"
echo "   oc get pods,svc -n mercury"
echo
echo "2. NetworkPolicy in mercury:"
echo "   oc get networkpolicy -n mercury"
echo
echo "3. Webapp pods & service:"
echo "   oc get pods,svc -n sun"
echo
echo "4. Check webapp logs for connection attempts:"
echo "   oc logs -f deployment/webapp -n sun"

