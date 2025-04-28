import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.upbound.azuread.groups.v1beta1 as groupsv1beta1
import models.io.upbound.azuread.applications.v1beta1 as applicationsv1beta1

oxr = scalebeyondv1alpha1.XTenant{**option("params").oxr}
azuread_provider_name = "upbound-provider-azuread"

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items = [
  groupsv1beta1.Group{
    metadata: _metadata(oxr.metadata.name + "-group")
    spec: {
      providerConfigRef: {
        name: azuread_provider_name #oxr.spec.parameters.floor
      }
      forProvider: {
        displayName: oxr.metadata.name
        securityEnabled: True
      }
    }
  }

  applicationsv1beta1.Application{
    metadata: _metadata(oxr.metadata.name + "-application")
    spec: {
      providerConfigRef: {
        name: azuread_provider_name #oxr.spec.parameters.floor
      }
      forProvider: {
        displayName: "infinitehotel-tenant-" + oxr.metadata.name
      }
    }
  }

]
items = _items
