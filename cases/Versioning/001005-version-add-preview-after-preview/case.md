# CASE 001005-version-add-preview-after-preview

## prompt

Add a new preview version `2025-05-04-preview` to my service widget resource manager. 

### Input Context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/blob/main/cases/Versioning/001005-version-add-preview-after-preview/tsp/main.tsp>

```tsp
import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.Core;
using Azure.ResourceManager;

/** Microsoft.Widget Resource Provider management API. */
@armProviderNamespace
@service(#{ title: "Widget" })
@versioned(Microsoft.Widget.Versions)
namespace Microsoft.Widget;

/** The available API versions. */
enum Versions {
  /** 2024-10-01-preview version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2024_10_01_preview: "2024-10-01-preview",
}

/** A Widget Employee resource */
model Employee is TrackedResource<EmployeeProperties> {
  ...ResourceNameParameter<Employee>;
}

/** Employee properties */
model EmployeeProperties {
  /** Age of employee */
  age?: int32;

  /** City of employee */
  city?: string;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** The resource provisioning state. */
@lroStatus
union ProvisioningState {
  ResourceProvisioningState,

  /** The resource is being provisioned */
  Provisioning: "Provisioning",

  /** The resource is updating */
  Updating: "Updating",

  /** The resource is being deleted */
  Deleting: "Deleting",

  /** The resource create request has been accepted */
  Accepted: "Accepted",

  string,
}

interface Operations extends Azure.ResourceManager.Operations {}

@armResourceOperations
interface Employees {
  get is ArmResourceRead<Employee>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Employee>;
  update is ArmCustomPatchSync<
    Employee,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<
      Employee,
      EmployeeProperties
    >
  >;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;
}
```

## user information collection

Based on the [General Case: One or more Stable Versions Exist](https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/02-preview-after-preview/#the-general-case-one-or-more-stable-versions-exist) guide:

### 1. Any types or properties that were `@added` in the previous preview should be removed in the new preview
- agent behavior: Ask the user whether any types or properties that were `@added` in the previous preview should be removed in the new preview.
- user input: Which types/properties to remove. 

### 2. Any types or properties that were `@removed` in the previous preview should now appear in the new preview
- agent behavior: Ask the user whether any types or properties that were `@removed` in the previous preview should now appear in the new preview.
- user input: Which types/properties to restore. 

### 3. Any renames, type changes, or optional changes from the previous preview that should be reverted?

- agent behavior: Ask the user whether any decorator-based changes from the previous preview (`@renamedFrom`, `@typeChangedFrom`, `@madeOptional`) should be reversed in the new preview.
- user input: Which changes to revert. 

## result

1. Add the new version `2025-05-04-preview` to the `Versions` enum

```tsp
/** The available API versions. */
enum Versions {
  /** 2025-05-04-preview version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  @previewVersion
  v2025_05_04_preview: "2025-05-04-preview",
}

/** Employee properties */
model EmployeeProperties {
  /** Age of employee */
  age?: int32;

  /** City of employee */
  city?: string;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;

  /** Email of employee */
  @added(Versions.v2025_05_04_preview)
  email?: string;
}
```

2. Example folders are correctly set up
rename the example folder from the old preview to the new one (e.g., `mv examples/2024-10-01-preview examples/2025-05-04-preview`), update the `api-version` parameter in all example files, and add or modify examples to reflect API changes.

3. For below each case below
- For Any types or properties that were `@added` in the previous preview should be removed in the new preview, for each one, the agent should simply delete the type or property (along with its `@added` decorator).
- For Any types or properties that were `@removed` in the previous preview should now appear in the new preview, For each one, the agent should remove the `@removed` decorator.
- Any renames, type changes, or optional changes from the previous preview that should be reverted, For each one:
  - `@renamedFrom`: Remove the decorator and revert the property to its old name.
  - `@typeChangedFrom`: Remove the decorator and revert the property to its old type.
  - `@madeOptional`: Remove the decorator and restore the property as required.

## Reference
- https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/02-preview-after-preview/#the-general-case-one-or-more-stable-versions-exist
