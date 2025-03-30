import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "XConcierge"
        spec= {
            assertResources: [
                {
                    apiVersion: "gitops.platform.upbound.io/v1alpha1"
                    kind: "XArgo"
                    metadata.name = "concierge"
                    spec: {
                        parameters: {
                            ingressUrl: "concierge.infinite-hotel.de"
                            providerConfigName: "zero"
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
                    metadata.name = "concierge-ingress"
                    spec: {
                        providerConfigRef: {
                            name: "zero"
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
                                            host: "concierge.infinite-hotel.de"
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
                                        "concierge.infinite-hotel.de"
                                    ]
                                    }]
                                }
                            }
                        }
                    }
                }
            ]
            compositionPath: "apis/xconcierges/composition.yaml"
            xr: scalebeyondv1alpha1.XConcierge{
                metadata: {
                    name = "concierge"
                    uid = "98738947398479283748923789327"
                }
                spec: {
                    parameters: {
                        lobby: "zero"
                        name: "concierge.infinite-hotel.de"
                    }
                }
            }
            xrdPath: "apis/xconcierges/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
