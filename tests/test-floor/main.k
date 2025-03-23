import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "XFloor"
        spec= {
            assertResources: [
                {
                    apiVersion: "azure.platform.upbound.io/v1alpha1",
                    kind: "XAKS",
                    metadata: {
                        name: "first",
                    },
                    spec: {
                        parameters: {
                            id: "zero"
                            region: "westus"
                            version: "1.31"
                            nodes: {
                                count: 3
                                instanceType: "Standard_B2s"
                            }
                        }
                    }
                }
                helmv1beta1.Release{
                    metadata: {
                        name: "first-cert-manager"
                        annotations: {
                            "crossplane.io/external-name": "cert-manager"
                        }
                    }
                    spec: {
                        forProvider: {
                            chart: {
                                name: "cert-manager"
                                repository: "https://charts.jetstack.io"
                                version: "v1.13.2"
                            }
                            namespace: "cert-manager"
                            values: {
                                installCRDs: True
                                global: {
                                    leaderElection: {
                                    namespace: "cert-manager"
                                    }
                                }
                            }
                        }
                        providerConfigRef: {
                            name: "zero"
                        }
                    }
                }

                kubernetesv1alpha2.Object{
                    metadata.name: "first-clusterissuer"
                    spec: {
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
                    metadata: {
                        name: "first-ingress"
                        annotations: {
                            "crossplane.io/external-name": "ingress-nginx"
                        }
                    }
                    spec: {
                        providerConfigRef: {
                            name: "zero"
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
            compositionPath: "apis/xfloors/composition.yaml"
            xr: scalebeyondv1alpha1.XFloor{
                metadata.name = "first"
                spec: {
                    parameters: {
                        lobby: "zero"
                        wing: "westus"
                        occupancyPermit: "1.31"
                        quermeters: {
                            count: 3
                            roomClass: "BasicSuite"
                        }
                    }
                }
            }
            xrdPath: "apis/xfloors/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
