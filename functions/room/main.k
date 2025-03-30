import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1

oxr = scalebeyondv1alpha1.XRoom{**option("params").oxr}

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
  helmv1beta1.Release{
    metadata: _metadata(oxr.metadata.labels["crossplane.io/claim-name"])
    spec: {
      providerConfigRef: {
        name: oxr.spec.parameters.floor
      }
      forProvider: {
        namespace: oxr.metadata.labels["crossplane.io/claim-name"]
        chart: {
          version: "0.24.0"
          repository: "https://charts.loft.sh"
          name: "vcluster"
        }
        values: {
          pro: False
          exportKubeConfig: {
            context: oxr.metadata.labels["crossplane.io/claim-name"]
            server:  "https://"+oxr.metadata.labels["crossplane.io/claim-name"]+"."+oxr.spec.parameters.floor+"."+oxr.spec.parameters.coordinates,
            secret: {
              name: oxr.metadata.labels["crossplane.io/claim-name"],
              namespace: oxr.metadata.labels["crossplane.io/claim-name"]
            }
          }
          sync: {
            toHost: {
              ingresses: {
                enabled: True
              }
            }
          }
          networking: {
            replicateServices: {
                fromHost: [
                    {
                        from: "room-service/food-server", 
                        to: "room-service/food-server"
                    }
                ]
            }
          }
          controlPlane: {
            ingress: {
              enabled: True
              host: oxr.metadata.labels["crossplane.io/claim-name"]+"."+oxr.spec.parameters.floor+"."+oxr.spec.parameters.coordinates
              pathType: "ImplementationSpecific"
              annotations: {
                "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
                "nginx.ingress.kubernetes.io/ssl-passthrough": "true"
                "nginx.ingress.kubernetes.io/ssl-redirect": "true"
              }
            }
            distro: {
              k3s: {
                enabled: True
              }
            }
            proxy: {
              extraSANs: [
                oxr.metadata.labels["crossplane.io/claim-name"],
                oxr.metadata.labels["crossplane.io/claim-name"]+"-"+oxr.metadata.labels["crossplane.io/claim-name"],
                oxr.metadata.labels["crossplane.io/claim-name"]+"-"+oxr.metadata.labels["crossplane.io/claim-name"]+".svc",
                oxr.metadata.labels["crossplane.io/claim-name"]+"-"+oxr.metadata.labels["crossplane.io/claim-name"]+".svc.cluster.local",
              ]
            }
          }
        }
      }
    }
  }
]
items = _items
