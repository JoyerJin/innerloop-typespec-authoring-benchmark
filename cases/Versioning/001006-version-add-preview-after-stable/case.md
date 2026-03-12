# CASE 001006-version-add-preview-after-stable

## prompt

Add a new preview version `2025-05-04-preview` to my service.

### Input Context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/blob/main/cases/Versioning/001006-version-add-preview-after-stable/tsp/main.tsp>

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

  /** 2024-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2024_10_01: "2024-10-01",
}

/** A Widget Employee resource */
model Employee is TrackedResource<EmployeeProperties> {
  ...ResourceNameParameter<Employee>;
}

/** Employee properties */
model EmployeeProperties {
  /** Age of employee (before 2025-11-01) */
  @removed(Versions.v2024_10_01)
  @renamedFrom(Versions.v2024_10_01, "age")
  oldAge?: int32;

  /** Age of employee (from 2025-11-01 onward, default is 21) */
  @added(Versions.v2024_10_01)
  age?: int32 = 21;

  /** City of employee */
  city?: string;

  /** Work location of employee */
  @added(Versions.v2024_10_01)
  workLocation?: WorkLocation;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** Work location details */
@added(Versions.v2024_10_01)
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

Based on the [Adding a Preview Version when the Last Version was Stable](https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/04-preview-after-stable/) guide:

### 1. Any types removed in the new preview?

- agent behavior: Ask the user whether any existing types or properties should be removed in the new preview version.
- user input: Which types/properties to remove. Mark each with an `@removed` decorator referencing the new preview version.

### 2. Any types added, renamed, or otherwise modified in the new preview?

- agent behavior: Ask the user what new types, properties, renames, or other modifications should be introduced in the new preview version.
- user input: Which changes to introduce. Mark each with the appropriate versioning decorator (`@added`, `@renamedFrom`, `@typeChangedFrom`, `@madeOptional`) referencing the new preview version.

### User input
1. I want to add/modify/remove features
2. Add a new property `department` of type `string` to `EmployeeProperties`.

## result

Scenario: **Adding a Preview Version when the Last Version was a Stable Version** — the latest existing version is stable, and the user wants to add a new preview version to iterate on new features.

1. Add the new version `2025-05-04-preview` to the `Versions` enum with `@previewVersion` decorator

2. Create a new examples folder for the new version `examples/2025-05-04-preview` and populate it with examples.

3. For each change the user identifies:
   - If a type/property is removed, add `@removed(Versions.v2025_05_04_preview)` decorator.
   - If a type/property is added, add `@added(Versions.v2025_05_04_preview)` decorator.
   - If a type/property is renamed, add `@renamedFrom(Versions.v2025_05_04_preview, "oldName")` decorator.
   - If a property type changed, add `@typeChangedFrom(Versions.v2025_05_04_preview, OldType)` decorator.
   - If a property is made optional, add `@madeOptional(Versions.v2025_05_04_preview)` decorator.

```tsp
/** The available API versions. */
enum Versions {
  /** 2021-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2021_10_01: "2021-10-01",

  /** 2024-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2024_10_01: "2024-10-01",

  /** 2025-05-04-preview version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  @Azure.Core.previewVersion
  v2025_05_04_preview: "2025-05-04-preview",
}

/** Employee properties */
model EmployeeProperties {
  /** Age of employee */
  age?: int32;

  /** City of employee */
  @removed(Versions.v2024_10_01)
  city?: string;

  /** Work location of employee */
  @added(Versions.v2024_10_01)
  workLocation?: WorkLocation;

  /** Profile of employee */
  @encode("base64url")
  profile?: bytes;

  /** Department of employee */
  @added(Versions.v2025_05_04_preview)
  department?: string;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}
```

## Reference
- https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/04-preview-after-stable/
