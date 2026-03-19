
# CASE 002002-ARM-define-extension-resource

## Prompt

add a extension resource asset

### Input context

properties: description: string, optional; assetType: string, optional; value: string, optional; provisioningState: Enum, optional, composed of:all values from ResourceProvisioningState,three additional fixed states: "Provisioning", "Updating", "Deleting",and a catch-all string value to permit unknown states returned by the service.

## Expected response

```tsp
import "@azure-tools/typespec-azure-resource-manager";

using Azure.ResourceManager;

namespace Microsoft.Widget;

/** The provisioning state of an Asset resource. */
@lroStatus
union AssetProvisioningState {
  ResourceProvisioningState,

  /** The resource is being provisioned. */
  Provisioning: "Provisioning",

  /** The resource is updating. */
  Updating: "Updating",

  /** The resource is being deleted. */
  Deleting: "Deleting",

  string,
}

/** Asset properties. */
model AssetProperties {
  /** A description of the asset. */
  description?: string;

  /** The type of the asset. */
  assetType?: string;

  /** The value of the asset. */
  value?: string;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: AssetProvisioningState;
}

/** An Asset extension resource. */
model Asset is ExtensionResource<AssetProperties> {
  ...ResourceNameParameter<Asset>;
}

@armResourceOperations
interface Assets {
  get is ArmResourceRead<Asset>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Asset>;
  update is ArmResourcePatchSync<Asset, AssetProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<Asset>;
  listByParent is ArmResourceListByParent<Asset>;
}
```

## Verify Plan
1. A new file should be created for the Asset resource definition.
2. The Asset model should be defined as an extension resource with its associated properties model.
3. The Asset properties model should include description, asset type, value, and a read-only provisioning state.
4. A provisioning state union type should be defined with standard ARM states plus custom states.
5. The Asset interface should include standard CRUD operations and a list-by-parent operation.

# Case reference

