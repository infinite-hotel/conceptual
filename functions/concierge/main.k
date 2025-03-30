import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

oxr = scalebeyondv1alpha1.XConcierge{**option("params").oxr}

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
        apiVersion: "gitops.platform.upbound.io/v1alpha1"
        kind: "XArgo"
        metadata: _metadata(oxr.metadata.name)
        spec: {
            parameters: {
                ingressUrl: oxr.spec.parameters.name
                providerConfigName: oxr.spec.parameters.lobby
                oidcConfig: """
                    name: Keycloak
                    issuer: https://{}/realms/master
                    clientID: argocd
                    clientSecret: {}
                    requestedScopes: ['openid', 'profile', 'email', 'groups']
                """.format(oxr.spec.parameters.gateguard, oxr.metadata.uid)
                source: {
                    git: {
                        url: "https://github.com/infinite-hotel/concierge.git"
                        path: "gitops"
                        ref: {
                            name: "HEAD"
                        }
                    }
                }
            }
        }
    }

    kubernetesv1alpha2.Object{
        metadata: _metadata(oxr.metadata.name+"-ingress")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                manifest: {
                    apiVersion: "networking.k8s.io/v1"
                    kind: "Ingress"
                    metadata: {
                        name: "argocd-server-ingress"
                        namespace: "argocd"
                        annotations: {
                            "cert-manager.io/cluster-issuer": "letsencrypt-prod"
                            "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
                        }
                    }
                    spec: {
                        ingressClassName: "nginx"
                        rules: [
                            {
                                host: oxr.spec.parameters.name
                                http: {
                                    paths: [
                                        {
                                            path: "/"
                                            pathType: "Prefix"
                                            backend: {
                                                service: {
                                                    name: "argocd-server"
                                                    port: {
                                                        name: "https"
                                                    }
                                                }
                                            }
                                        }
                                    ]
                                }
                            }
                        ]
                        tls: [{
                           secretName: "argocd-server-tls"
                           hosts: [
                            oxr.spec.parameters.name
                           ]
                        }]
                    }
                }
            }
        }
    }

    kubernetesv1alpha2.Object{
        metadata: _metadata(oxr.metadata.name+"-clientsecret")
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "v1"
                    kind: "Secret"
                    metadata: {
                        name: "concierge-{}".format(oxr.spec.parameters.lobby)
                        namespace: "crossplane-system"
                    }
                    type: "Opaque"
                    stringData: {
                        clientSecret: oxr.metadata.uid
                    }
                }
            }
        }
    }

    {
        apiVersion: "group.keycloak.crossplane.io/v1alpha1"
        kind: "Group"
        metadata: _metadata(oxr.metadata.name+"-group") | {
            labels: {
                name: "argocd-admin"
            }
        }
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                name: "argocd-admin"
                realmId: "master"
            }
        }
    }

    {
        apiVersion: "openidclient.keycloak.crossplane.io/v1alpha1"
        kind: "ClientScope"
        metadata: _metadata(oxr.metadata.name+"-client-scope")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                realmId: "master"
                name: "groups"
                includeInTokenScope: True
                guiOrder: 1
            }
        }
    }

    {
        apiVersion: "openidgroup.keycloak.crossplane.io/v1alpha1"
        kind: "GroupMembershipProtocolMapper"
        metadata: _metadata(oxr.metadata.name+"-gmpm")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                clientId: option("params").ocds[oxr.metadata.name+"-client"]?.Resource?.status?.atProvider?.id
                clientScopeId: option("params").ocds[oxr.metadata.name+"-client-scope"]?.Resource?.status?.atProvider?.id
                realmId: "master"
                name: "groups"
                claimName: "groups"
                fullPath: False
            }
        }
    }

    {
        apiVersion: "openidclient.keycloak.crossplane.io/v1alpha1"
        kind: "ClientDefaultScopes"
        metadata: _metadata(oxr.metadata.name+"-cds")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                clientId: option("params").ocds[oxr.metadata.name+"-client"]?.Resource?.status?.atProvider?.id
                realmId: "master"
                defaultScopes: [
                    "profile"
                    "email"
                    "roles"
                    "web-origins"
                    "groups"
                ]
            }
        }
    }

    {
        apiVersion: "openidclient.keycloak.crossplane.io/v1alpha1"
        kind: "Client"
        metadata: _metadata(oxr.metadata.name+"-client")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                realmId: "master"
                clientId: "argocd"
                baseUrl: "/applications"
                name: "argocd"
                enabled: True
                accessType: "CONFIDENTIAL"
                clientSecretSecretRef: {
                    namespace: "crossplane-system"
                    key: "clientSecret"
                    name: "concierge-{}".format(oxr.spec.parameters.lobby)
                }
                standardFlowEnabled: True
                directAccessGrantsEnabled: True
                validRedirectUris: [
                    "https://{}/*".format(oxr.spec.parameters.name)
                ]
                webOrigins: [
                    "https://{}".format(oxr.spec.parameters.name)
                ]
                validPostLogoutRedirectUris: [
                    "https://{}".format(oxr.spec.parameters.name)
                ]
                rootUrl: "https://{}".format(oxr.spec.parameters.name)
                adminUrl: "https://{}".format(oxr.spec.parameters.name)
            }
        }
    }

]
items = _items
