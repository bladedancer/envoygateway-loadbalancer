#!/bin/sh

. ./.env

cat << EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: demo-loadbalancer
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: demo-http
  loadBalancer:
    type: ConsistentHash
    consistentHash:
      type: SourceIP
EOF

echo "To test: curl http://$DOMAIN/test"

for i in 1 2 3 4 5
do
    curl http://$DOMAIN/test
    sleep 5
done