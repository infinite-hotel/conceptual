import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "XGateGuard"
        spec= {
            assertResources: [
                helmv1beta1.Release{
                    metadata: {
                        name: "keycloak"
                        annotations: {
                            "crossplane.io/external-name": "keycloak"
                            "crossplane.io/composition-resource-name": "keycloak"
                        }
                    }
                    spec: {
                        providerConfigRef: {
                            name: "zero"
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
                                hostname: "gateguard.infinite-hotel.de"
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
            ]
            compositionPath: "apis/xgateguards/composition.yaml"
            xr: scalebeyondv1alpha1.XGateGuard{
                metadata.name = "gateguard"
                spec: {
                    parameters: {
                        lobby: "zero"
                        name: "gateguard.infinite-hotel.de"
                    }
                }
            }
            xrdPath: "apis/xgateguards/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
