# CASE 001012-version-operation-return-type-changed

## Prompt

In the specification/widget/resource-manager/Microsoft.Widget/Widget project, change the return type of the `exportData` operation from `ExportResult` to `DetailedExportResult` with additional properties `format` (string) and `exportedAt` (utcDateTime) only for version `2025-05-04-preview`.

### Input context

```tsp
import "@typespec/rest";
import "@typespec/http";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;
using Azure.ResourceManager;

namespace Microsoft.Widget;

/** Employee resource */
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

/** Export result model */
model ExportResult {
  /** Exported data */
  data?: string;
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

@armResourceOperations
interface Employees {
  get is ArmResourceRead<Employee>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Employee>;
  update is ArmResourcePatchSync<Employee, EmployeeProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;

  /** Export employee data */
  exportData is ArmResourceActionSync<Employee, void, ExportResult>;
}
```

## Expected response

```tsp
/** Export result model */
model ExportResult {
  /** Exported data */
  data?: string;
}

/** Detailed export result model */
@added(Versions.v2025_05_04_preview)
model DetailedExportResult {
  /** Exported data */
  data?: string;

  /** Format of exported data */
  format?: string;

  /** Timestamp of export */
  exportedAt?: utcDateTime;
}

@armResourceOperations
interface Employees {
  get is ArmResourceRead<Employee>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Employee>;
  update is ArmResourcePatchSync<Employee, EmployeeProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;

  /** Export employee data */
  @returnTypeChangedFrom(Versions.v2025_05_04_preview, ExportResult)
  exportData is ArmResourceActionSync<Employee, void, DetailedExportResult>;
}
```

## Verify Plan
1. A new `DetailedExportResult` model should be created containing `data`, `format`, and `exportedAt` properties.
2. The `exportData` operation should have `@returnTypeChangedFrom(Versions.v2025_05_04_preview, ExportResult)` decorator added and its return type changed to `DetailedExportResult`.

## Case reference
