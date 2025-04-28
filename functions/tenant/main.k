import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1

oxr = scalebeyondv1alpha1.XTenant{**option("params").oxr}
azuread_provider_name = "upbound-provider-azuread"

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
      "crossplane.io/external-name" = name
    }
  }
}

_items = [
  azureadv1beta1.Group{
    metadata: _metadata(oxr.metadata.labels["crossplane.io/claim-name"])
    spec {
      providerConfigRef: {
        name: azuread_provider_name #oxr.spec.parameters.floor
      }
      forProvider: {
        displayName: name
        securityEnabled: True
      }


# metadata:
#   annotations:
#     meta.upbound.io/example-id: groups/v1beta1/group
#   labels:

  azureadv1beta1.Application{
    metadata: _metadata(oxr.metadata.labels["crossplane.io/claim-name"])
    spec: {
      providerConfigRef: {
        name: azuread_provider_name #oxr.spec.parameters.floor
      }
      forProvider: {
        displayName: "infinitehotel-tenant-${name}"
        securityEnabled: True
      }
    }
  }


# apiVersion: applications.azuread.upbound.io/v1beta2
# kind: Application
# metadata:
#   annotations:
#     meta.upbound.io/example-id: applications/v1beta1/application
#   labels:
#     testing.upbound.io/example-name: example
#   name: example
# spec:
#   forProvider:
#     displayName: example-random

    }
  }

]
items = _items
