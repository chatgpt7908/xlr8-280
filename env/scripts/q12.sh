#!/bin/bash

echo "[+] Creating project 'math'..."
oc new-project math >/dev/null 2>&1 || oc project math

echo "[+] Applying YAML (Deployment + Service + Route)..."
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: qed
  namespace: math
spec:
  selector:
    app: qed
  ports:
    - name: web
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qed
  namespace: math
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qed
  template:
    metadata:
      labels:
        app: qed
    spec:
      containers:
        - name: nginx
          image: quay.io/redhattraining/hello-world-nginx
          ports:
            - containerPort: 8080
          command:
            - /bin/sh
            - -c
            - |
              if [ -z "\$DECODER_RING" ]; then
                echo "ERROR: App is not configured properly!"
                exit 1
              fi
              echo "Application working successfully: \$DECODER_RING"
              nginx -g 'daemon off;'
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: qed
  namespace: math
spec:
  to:
    kind: Service
    name: qed
  port:
    targetPort: web
EOF

echo "[+] Resources created."

