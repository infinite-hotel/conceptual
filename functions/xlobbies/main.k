import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1

oxr = scalebeyondv1alpha1.XLobby{**option("params").oxr}

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items = [
  platformazurev1alpha1.XNetwork{
    metadata: _metadata(oxr.metadata.name),
    spec: {
      parameters: {
        id: oxr.metadata.name,
        region: oxr.spec.parameters.wing,
      }
    }
  }
]
items = _items
