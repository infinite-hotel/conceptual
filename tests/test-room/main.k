import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "XRooms"
        spec= {
            assertResources: [
                helmv1beta1.Release{
                    metadata.name: "room001-infinity"
                    spec: {
                    providerConfigRef: {
                        name: "zero"
                    }
                    forProvider: {
                        namespace: "room001-infinity"
                        chart: {
                            version: "0.24.0"
                            repository: "https://charts.loft.sh"
                            name: "vcluster"
                        }
                        values: {
                            pro: False
                            exportKubeConfig: {
                                context: "room001-infinity"
                                server:  "https://room001-infinity.zero.infinite-hotel.de"
                                secret: {
                                name: "room001-infinity",
                                namespace: "room001-infinity"
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
                                host: "room001-infinity.zero.infinite-hotel.de"
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
                                    "room001-infinity",
                                    "room001-infinity-room001-infinity"
                                    "room001-infinity-room001-infinity.svc",
                                    "room001-infinity-room001-infinity.svc.cluster.local",
                                ]
                                }
                            }
                        }
                    }
                    }
                }
            ]
            compositionPath: "apis/xrooms/composition.yaml"
            xr: scalebeyondv1alpha1.XRoom{
                metadata: {
                    name = "room001-infinity-abcdef"
                    labels: {
                        "crossplane.io/claim-name": "room001-infinity"
                    }
                }
                spec: {
                    parameters: {
                        floor: "zero"
                    }
                }
            }
            xrdPath: "apis/xrooms/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
