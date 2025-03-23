import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1

oxr = scalebeyondv1alpha1.XPenthouse{**option("params").oxr}

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items = [
    kubernetesv1alpha2.Object{
        metadata: _metadata(oxr.metadata.name)
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "spaces.upbound.io/v1beta1"
                    kind: "ControlPlane"
                    metadata: {
                        name: oxr.metadata.name
                        namespace: "default"
                    }
                    spec: {
                        crossplane: {
                            autoUpgrade: {
                                channel: "Rapid"
                            }
                        }
                        writeConnectionSecretToRef: {
                            name: oxr.metadata.name
                        }
                    }
                }
            }
        }
    }
]
items = _items
