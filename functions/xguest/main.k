import models.io.rejekts.scalebeyond.v1alpha1 as scalebeyondv1alpha1

oxr = scalebeyondv1alpha1.XGuest{**option("params").oxr}

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
        apiVersion: "user.keycloak.crossplane.io/v1alpha1"
        kind: "User"
        metadata: _metadata(oxr.metadata.name+"-user")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                realmId: "master"
                enabled: True
                emailVerified: True
                username: oxr.spec.parameters.username
                firstName: oxr.spec.parameters.firstName
                lastName: oxr.spec.parameters.lastName
                initialPassword: oxr.spec.parameters.initialPassword
                email: oxr.spec.parameters.email
            }
        }
    }

    {
        apiVersion: "user.keycloak.crossplane.io/v1alpha1"
        kind: "Groups"
        metadata: _metadata(oxr.metadata.name+"-grp")
        spec: {
            providerConfigRef: {
                name: oxr.spec.parameters.lobby
            }
            forProvider: {
                realmId: "master"
                userIdSelector: {
                    matchControllerRef: True
                }
                groupIdsSelector: {
                    matchLabels: {
                        name: oxr.spec.parameters.group
                    }
                }
            }
        }
    }

]
items = _items