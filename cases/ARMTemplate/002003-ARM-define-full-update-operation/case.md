# CASE 002003-ARM-full-update-operation

## Prompt

Define a PATCH operation of Employees. It is to update properties of an employee. Ensure the definition meets TypeSpec Azure guidelines.

### Input context
<https://github.com/Azure/azure-rest-api-specs/pull/37109>
<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/tree/main/cases/ARMTemplate/002003-ARM-define-full-update-operation/tsp/employee.tsp>

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
  /**It incorrectly uses ARMResourcePatch* as the operation template.**/
  update is ArmResourcePatchAsync<
    Employee,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<Employee, EmployeeProperties>
  >;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;
}
```

## Expected response

Full update operation (PATCH) should be defined as "update is ArmCustomPatchAsync<Resource, PatchRequest>;" or "update is ArmCustomPatchAsync<Resource, PatchRequest>;".

```tsp
@armResourceOperations
interface Employees {

  update is ArmCustomPatchAsync<
    Employee,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<Employee, EmployeeProperties>
  >;
  
}
```

## Verify Plan
1. update operation change from ArmResourcePatchAsync to ArmCustomPatchAsync

## Case reference
[ARM Resource Operations - Resource Update Operations (PATCH)](https://azure.github.io/typespec-azure/docs/howtos/arm/resource-operations/#resource-update-operations-patch)