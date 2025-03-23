# The Infinite Hotel: Scaling Multi-Tenant Platforms through a Unified API.

<p align="center">
  <img src="infinite-hotel.png" alt="Infinite Hotel Blueprint" />
</p>

As platform teams evolve, platforms extend beyond infrastructure to application
services, cloud resource management, and middleware orchestration. Managing
these distributed components across clusters and teams demands a unified,
scalable approach. This session shows how to manage infrastructure, tenants, and
application services entirely through Kubernetes by building a modular,
multi-tenant, multi-control-plane platform. Attendees will learn to extend the
Kubernetes API with Control Planes for distributed, tenant-aware infrastructure
management. We will explore CNCF projects to create abstractions and automation,
enabling platform teams to offer consistent services and self-service
capabilities. Topics include multi-tenancy with in- and out-of-cluster
isolation, unified APIs for control-plane orchestration, and avoiding common
pitfalls in multi-control-plane management. By the end, attendees will have a
roadmap for scalable platforms supporting centralized and tenant-managed
services.

## Hotel Manager

```
up login
up ctx infinite-hotel/upbound-gcp-us-central-1/default
up ctp create hilbert
up ctx infinite-hotel/upbound-gcp-us-central-1/default/hilbert
kubectl apply -f examples/configuration.yaml
# https://docs.upbound.io/providers/provider-azure/authentication/#upbound-auth-oidc
kubectl apply -f examples/providerconfig.yaml
```

## Lobby
    - Network

```
kubectl apply -f examples/xlobby/zero.yaml
```

## Concierge
    - ArgoCD

```
kubectl apply -f examples/concierge/concierge.yaml
```

## GateGuard
    - Keycloak

```
kubectl apply -f examples/gateguard/gateguard.yaml
```

## Floor
    - Azure AKS Cluster

```
kubectl apply -f examples/floor/first.yaml
```

## Room
    - vCluster

```
kubectl apply -f examples/room/room001-infinity.yaml
```

## Penthouse
    - Upbound ControlPlane

```
up login
up robot create "provider-kubernetes" --description="Robot used for authenticating to Upbound by provider-kubernetes"
export UPBOUND_TOKEN=$(up robot token create "provider-kubernetes" "provider-kubernetes-token" --output=-| awk -F': ' '/Token:/ {print $2}')
up login -t $UPBOUND_TOKEN
up ctx $@<org>/<space>>/<group>/<control-plane>$@
up ctx . -f - > upbound-context.yaml
export CONTROLPLANE_CONFIG=upbound-context.yaml

kubectl -n crossplane-system create secret generic cluster-config --from-file=kubeconfig=$CONTROLPLANE_CONFIG
kubectl -n crossplane-system create secret generic upbound-credentials --from-literal=token=$UPBOUND_TOKEN
```
