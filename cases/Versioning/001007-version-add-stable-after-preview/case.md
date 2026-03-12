# CASE 001007-version-add-stable-after-preview

## prompt

I want to add a new stable version `2025-01-01`.

### Input Context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/blob/main/cases/Versioning/001007-version-add-stable-after-preview/tsp/main.tsp>

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
  /** 2021-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2021_10_01: "2021-10-01",

  /** 2024-10-01-preview version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  @previewVersion
  v2024_10_01_preview: "2024-10-01-preview",
}

/** A Widget Employee resource */
model Employee is TrackedResource<EmployeeProperties> {
  ...ResourceNameParameter<Employee>;
}

/** Employee properties */
model EmployeeProperties {
  /** Age of employee (before 2025-11-01) */
  @removed(Versions.v2024_10_01_preview)
  @renamedFrom(Versions.v2024_10_01_preview, "age")
  oldAge?: int32;

  /** Age of employee (from 2025-11-01 onward, default is 21) */
  @added(Versions.v2024_10_01_preview)
  age?: int32 = 21;

  /** City of employee */
  city?: string;

  /** Work location of employee */
  @added(Versions.v2024_10_01_preview)
  workLocation?: WorkLocation;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** Work location details */
@added(Versions.v2024_10_01_preview)
model WorkLocation {
  /** Country */
  country?: string;

  /** Company */
  company?: string;

  /** Seat number */
  seatNumber?: string;
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

Based on the [Adding a Stable Version when the Last Version was Preview](https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/03-stable-after-preview/) guide:

### 1. Which type changes from the latest preview are now stable?

- agent behavior: Ask the user which types, properties, or changes introduced in the latest preview version should be carried forward into the new stable version.
- user input: Which preview changes are now stable. Update their versioning decorators to reference the new stable version instead of the preview version.

### 2. Which changes from the latest preview are NOT in the new stable version?

- agent behavior: Ask the user which types, properties, or changes from the latest preview should NOT appear in the new stable version.
- user input: Which preview changes to revert.

### 3. Any additional changes in the new stable version?

- agent behavior: Ask the user whether there are any additional types, properties, or modifications to introduce in the new stable version beyond what was in the preview.
- user input: Which new changes to introduce. Mark each with the appropriate versioning decorator referencing the new stable version.

### User Input for test
1. model WorkLocation is stable
2. city removal is not stable
3. city property in WorkLocation will be removed

## result

Scenario: **Adding a Stable Version when the Last Version was a Preview** — the latest existing version is a preview, and the user wants to promote the API to stable.

1. Add the new stable version `2025-01-01` to the `Versions` enum, remove the preview version from the enum

```tsp
/** The available API versions. */
enum Versions {
  /** 2021-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2021_10_01: "2021-10-01",

  /** 2025-01-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2025_01_01: "2025-01-01",
}
```

2. Rename example folder from the old preview to the new stable version (e.g., `mv examples/2024-10-01-preview examples/2025-01-01`), update the `api-version` parameter in all example files, and add or modify examples to reflect API changes.

3. For each preview change the user identifies:
   - For preview changes that ARE now stable: update the versioning decorator to reference the new stable version (e.g., `@added(Versions.v2024_10_01_preview)` → `@added(Versions.v2025_01_01)`).
   - For preview changes that are NOT stable:
     - `@added`: Delete the type/property entirely.
     - `@typeChangedFrom`: Revert the property to its old type, remove the decorator.
     - `@returnTypeChangedFrom`: Revert the return type, remove the decorator.
     - `@renamedFrom`: Revert to the old name, remove the decorator.
     - `@madeOptional`: Make the property required again, remove the decorator.
     - `@removed`: Remove the decorator (restoring the type).

```tsp
/** Employee properties */
model EmployeeProperties {
  /** Age of employee */
  age?: int32;

  /** City of employee */
  city?: string;

  /** Work location of employee */
  @added(Versions.v2025_01_01)
  workLocation?: WorkLocation;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** Work location details */
@added(Versions.v2025_01_01)
model WorkLocation {
  /** Country */
  country?: string;

  /** Company */
  company?: string;

  /** Seat number */
  seatNumber?: string;
}
```

## Reference
- https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/03-stable-after-preview/
