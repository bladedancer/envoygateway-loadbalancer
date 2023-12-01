#!/bin/sh

. ./.env

helm delete -n $NAMESPACE eg
kubectl delete namespace $NAMESPACE