import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

oxr = scalebeyondv1alpha1.XGateGuard{**option("params").oxr}

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
        metadata: _metadata("keycloak")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                namespace: "keycloak"
                chart: {
                  repository: "oci://registry-1.docker.io/bitnamicharts"
                  name: "keycloak"
                }
                values: {
                  auth: {
                    createAdminUser: True
                    adminUser: "admin"
                    adminPassword: "admin"
                    managementUser: "manager"
                    managementPassword: "manager"
                  }
                  proxyAddressForwarding: True
                  proxy: "edge"
                  metrics: {
                    enabled: False
                    serviceMonitor: {
                      enabled: False
                    }
                  }
                  ingress: {
                    hostname: oxr.spec.parameters.name
                    enabled: True
                    annotations: {
                      "kubernetes.io/ingress.class": "nginx"
                      "cert-manager.io/cluster-issuer": "letsencrypt-prod"
                    }
                    tls: True
                    selfSigned: False
                  }
                  postgresql: {
                    enabled: True
                    auth: {
                      postgresPassword: "password"
                      password: "password"
                    }
                    metrics: {
                      enabled: False
                      serviceMonitor: {
                        enabled: False
                      }
                    }
                  }
                }
            }
        }
    }

    {
      apiVersion: "keycloak.crossplane.io/v1beta1"
      kind: "ProviderConfig"
      metadata: {
        name: oxr.spec.parameters.lobby
        annotations: {
          "krm.kcl.dev/composition-resource-name" = "providerconfig-keycloak"
          "krm.kcl.dev/ready": "True"
        }
      }
      spec: {
        credentials: {
          source: "Secret"
          secretRef: {
            key: "credentials"
            name: oxr.spec.parameters.name+"-keycloak"
            namespace: "crossplane-system"
          }
        }
      }
    }

    kubernetesv1alpha2.Object{
        metadata: _metadata(oxr.metadata.name+"-keycloak")
        spec: {
          forProvider: {
            manifest: {
              apiVersion: "v1"
              kind: "Secret"
              metadata: {
                name: oxr.spec.parameters.name+"-keycloak"
                namespace: "crossplane-system"
              }
              type: "Opaque"
              stringData: {
                credentials: """{{
                  "client_id": "admin-cli",
                  "client_secret": "",
                  "username": "admin",
                  "password": "admin",
                  "url": "https://{}",
                  "realm": "master"
                }}""".format(oxr.spec.parameters.name)
              }
            }
          }
        }
    }

]
items = _items