import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "XLobby"
        spec= {
            assertResources: [
                platformazurev1alpha1.XNetwork{
                    metadata.name: "zero"
                    spec: {
                        parameters: {
                            id: "zero"
                            region: "westus"
                        }
                    }
                }
            ]
            compositionPath: "apis/xlobbies/composition.yaml"
            xrPath: "examples/xlobby/zero.yaml"
            xrdPath: "apis/xlobbies/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items