# 1. Taint master node to break scheduling
oc adm taint node master01 dbz=goku:NoSchedule --overwrite

# 2. Create or switch to bluewills project
oc new-project bluewills || oc project bluewills

# 3. Create deployment (no toleration → pod will go Pending)
oc create deployment rocky --image=quay.io/redhattraining/hello-world-nginx

# 4. Expose deployment as a service
oc expose deployment rocky --port=8080

# 5. Create WRONG route (intentionally broken)
oc expose svc rocky --hostname=rocky.app.ocp.example.com

# 6. Show current state (pod will be Pending + wrong route)
oc get all | grep deploy
oc get pods -o wide
oc get route

