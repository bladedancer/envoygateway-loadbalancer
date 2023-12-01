#!/bin/sh

. ./.env

ENVOY_DEPLOYMENT=$(kubectl get deployment -n $NAMESPACE --selector=gateway.envoyproxy.io/owning-gateway-namespace=$NAMESPACE,gateway.envoyproxy.io/owning-gateway-name=demo-gateway -o jsonpath='{.items[0].metadata.name}')

kubectl rollout restart -n $NAMESPACE deployment $ENVOY_DEPLOYMENT

for i in 1 2 3 4 5
do
    curl http://$DOMAIN/test
    sleep 5
done