# CASE 001008-version-add-stable-after-stable

## prompt

Add a new stable version `2025-01-01` to my service. In this new version, I want to add a new property `department` of type `string` to `EmployeeProperties`.

### Input Context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/blob/main/cases/Versioning/001008-version-add-stable-after-stable/tsp/main.tsp>

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

Based on the [Adding a Stable Version when the Last Version was Stable](https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/05-stable-after-stable/) guide:

- agent behavior: - Goal: Add stable version 2025-01-01 to 001008 project with new department property
│  - File: 001008-version-add-stable-after-stable/tsp/main.tsp
│  - Steps:
│  1. Add v2025_01_01 entry to Versions enum
│  2. Add department?: string with @added(Versions.v2025_01_01) to EmployeeProperties
│  3. Run TypeSpec validation
│  - Result: department only appears in 2025-01-01; all existing features carried forward
- user input: Accept plan and build on autopilot (recommended)

## result

Scenario: **Adding a Stable Version when the Last Version was a Stable Version** — the latest existing version is already stable, and the user wants to add another stable version.

1. Add the new stable version `2025-01-01` to the `Versions` enum

2. Create a new examples folder for the new version `examples/2025-01-01` and populate it with examples.

3. For each change the user identifies:
   - If a type/property is removed, add `@removed(Versions.v2025_01_01)` decorator.
   - If a type/property is added, add `@added(Versions.v2025_01_01)` decorator.
   - If a type/property is renamed, add `@renamedFrom(Versions.v2025_01_01, "oldName")` decorator.
   - If a property type changed, add `@typeChangedFrom(Versions.v2025_01_01, OldType)` decorator.
   - If a property is made optional, add `@madeOptional(Versions.v2025_01_01)` decorator.

```tsp
/** The available API versions. */
enum Versions {
  /** 2021-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2021_10_01: "2021-10-01",

  /** 2024-10-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2024_10_01: "2024-10-01",

  /** 2025-01-01 version */
  @armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
  v2025_01_01: "2025-01-01",
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

  /** Department of employee */
  @added(Versions.v2025_01_01)
  department?: string;

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
```

## Reference
- https://azure.github.io/typespec-azure/docs/howtos/versioning/arm/05-stable-after-stable/
