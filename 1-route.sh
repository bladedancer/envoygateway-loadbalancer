#!/bin/sh

. ./.env

cat << EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: demo-http
spec:
  parentRefs:
    - name: demo-gateway
      sectionName: demo-http
  rules:
    - backendRefs:
        - group: ""
          kind: Service
          name: demo-echoserver
          port: 8080
          weight: 1
EOF

echo "To test: curl http://$DOMAIN/test"
curl http://$DOMAIN/test