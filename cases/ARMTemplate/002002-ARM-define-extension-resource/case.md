
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
1. Add asset.tsp file.
2. Add new model Asset defined as ExtensionResource<AssetProperties> with ResourceNameParameter.
3. Add new model AssetProperties with 4 properties (description, assetType, value and provisioningState).
4. Add Union AssetProvisioningState.
5. Add Asset interface operations: get, createOrUpdate (async), update (sync patch), delete (async), listByParent.

# Case reference

