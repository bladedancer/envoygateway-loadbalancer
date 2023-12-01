The issue is that when a backend traffic policy is applied the route works for about 15 seconds before envoy gets a:

[2023-11-30 23:00:13.570][1][warning][config] [source/extensions/config_subscription/grpc/grpc_subscription_impl.cc:130] gRPC config: initial fetch timed out for type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment

After which the cluster is removed and the route starts returning an unhealthy upstream error. 

./setup.sh - installs the envoy gateway, creates a gateway and installs a test service.
./1-route.sh - set up the http route
./2-loadbalancer-sticky.sh - create a backend traffic policy with consistent hash. (Issue occurs for all loadbalancer policies except least requests).
./3-restartgateway.sh - on restart the route starts working as expected (making me think it's related to https://github.com/envoyproxy/envoy/issues/13009)
./clean.sh - clean up everything.
