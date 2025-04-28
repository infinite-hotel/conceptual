import models.io.upbound.azuread.applications.v1beta1 as applicationsv1beta1
import models.io.upbound.azuread.groups.v1beta1 as groupsv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "xtenants"
        spec= {
            assertResources: [
                groupsv1beta1.Group{
                    metadata: {
                        annotations: {
                            "crossplane.io/composition-resource-name": "family-1-group"
                        }
                        name: "family-1-group"
                    }
                    spec: {
                        forProvider: {
                            displayName: "family-1"
                            securityEnabled: True
                        }
                        providerConfigRef: {
                            name: "upbound-provider-azuread"
                        }
                    }
                }
                applicationsv1beta1.Application{
                    metadata: {
                        annotations: {
                            "crossplane.io/composition-resource-name": "family-1-application"
                        }
                        name: "family-1-application"
                    }
                    spec: {
                        forProvider: {
                            displayName: "infinitehotel-tenant-family-1"
                        }
                        providerConfigRef: {
                            name: "upbound-provider-azuread"
                        }
                    }
                }
            ]
            compositionPath: "apis/xtenants/composition.yaml"
            xrPath: "examples/tenant/family1.yaml"
            xrdPath: "apis/xtenants/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items