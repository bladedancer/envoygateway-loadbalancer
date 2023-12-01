#!/bin/sh

. ./.env


# Install the gateway
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n $NAMESPACE --create-namespace
kubectl wait --timeout=5m -n $NAMESPACE deployment/envoy-gateway --for=condition=Available

# Create the gateway
cat << EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: demo-gatewayclass
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
spec:
  gatewayClassName: demo-gatewayclass
  listeners:
    - name: demo-http
      protocol: HTTP
      port: 80
      hostname: $DOMAIN
EOF


# Install a service to use for demo
cat << EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: v1
kind: Service
metadata:
  name: demo-echoserver
  labels:
    run: demo-echoserver
spec:
  ports:
    - port: 8080
      targetPort: 3000
      protocol: TCP
  selector:
    run: demo-echoserver
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-echoserver
spec:
  selector:
    matchLabels:
      run: demo-echoserver
  replicas: 3
  template:
    metadata:
      labels:
        run: demo-echoserver
    spec:
      containers:
        - name: demo-echoserver
          image: gcr.io/k8s-staging-ingressconformance/echoserver:v20221109-7ee2f3e
          ports:
            - containerPort: 8080
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
EOF

kubectl wait --timeout=5m -n $NAMESPACE deployment/demo-echoserver --for=condition=Available

# Update etc hosts
ENVOY_SERVICE=$(kubectl get svc -n $NAMESPACE --selector=gateway.envoyproxy.io/owning-gateway-namespace=$NAMESPACE,gateway.envoyproxy.io/owning-gateway-name=demo-gateway -o jsonpath='{.items[0].metadata.name}')
GATEWAY_IP=$(kubectl get svc/${ENVOY_SERVICE} -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo Set /etc/hosts with:
echo $DOMAIN: $GATEWAY_IP
sudo sed -i "/$DOMAIN/d" /etc/hosts
sudo sh -c "echo $GATEWAY_IP $DOMAIN >> /etc/hosts"
