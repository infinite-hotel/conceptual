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
]
items = _items
