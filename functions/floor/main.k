import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

oxr = scalebeyondv1alpha1.XFloor{**option("params").oxr}

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_items = [
  {
    apiVersion: "azure.platform.upbound.io/v1alpha1",
    kind: "XAKS",
    metadata: _metadata(oxr.metadata.name)
    spec: {
      parameters: {
        id: oxr.spec.parameters.lobby
        region: oxr.spec.parameters.wing
        version: oxr.spec.parameters.occupancyPermit
        nodes: {
          count: oxr.spec.parameters.quermeters.count
          if oxr.spec.parameters.quermeters.roomClass == "BasicSuite":
            instanceType: "Standard_B2s"
        }
      }
      writeConnectionSecretToRef: {
        name: oxr.metadata.name
        namespace: "crossplane-system"
      }
    }
  }

  helmv1beta1.Release{
    metadata: _metadata(oxr.metadata.name+"-cert-manager") | {
      annotations: {
        "crossplane.io/external-name" = "cert-manager"
      }
    }
    spec: {
      providerConfigRef: {
        name: oxr.spec.parameters.lobby
      }
      forProvider: {
        wait: True
        namespace: "cert-manager"
        chart: {
          version: "v1.13.2"
          repository: "https://charts.jetstack.io"
          name: "cert-manager"
        }
        values: {
          installCRDs: True
          global: {
            leaderElection: {
              namespace: "cert-manager"
            }
          }
        }
      }
    }
  }

  kubernetesv1alpha2.Object{
    metadata: _metadata(oxr.metadata.name+"-clusterissuer")
    spec: {
      providerConfigRef: {
        name: oxr.spec.parameters.lobby
      }
      forProvider: {
        manifest: {
          apiVersion: "cert-manager.io/v1"
          kind: "ClusterIssuer"
          metadata: {
            name: "letsencrypt-prod"
          }
          spec: {
            acme: {
              server: "https://acme-v02.api.letsencrypt.org/directory"
              privateKeySecretRef: {
                name: "letsencrypt-prod"
              }
              solvers: [{
                http01: {
                  ingress: {
                    ingressClassName: "nginx"
                  }
                }
              }]
            }
          }
        }
      }
    }
  }

  helmv1beta1.Release{
    metadata: _metadata(oxr.metadata.name+"-ingress") | {
      annotations: {
        "crossplane.io/external-name" = "ingress-nginx"
      }
    }
    spec: {
      providerConfigRef: {
        name: oxr.spec.parameters.lobby
      }
      forProvider: {
        wait: True
        namespace: "ingress-nginx"
        chart: {
          version: "4.7.1"
          repository: "https://kubernetes.github.io/ingress-nginx"
          name: "ingress-nginx"
        }
        values: {
            controller: {
              service: {
                type: "LoadBalancer"
                annotations: {
                  "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path": "/healthz"
                }
              }
              extraArgs: {
                "enable-ssl-passthrough": True
              }
            }
        }
      }
    }
  }
]
items = _items