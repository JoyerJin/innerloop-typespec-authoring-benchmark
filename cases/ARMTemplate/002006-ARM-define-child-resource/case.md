# CASE 002006-ARM-define-child-resource
## Prompt

Create a new "AddressResource" child resource under the parent resource "Employee". Ensure the definition meets TypeSpec Azure design guidelines.

### Input context

```tsp
//Employee.tsp

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
  update is ArmResourcePatchSync<Employee, EmployeeProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;
}
```

## Expected response

You can create parent/child relationships between resource types by using the @parentResource decorator when defining a resource type.

```tsp
//address.tsp
import "@typespec/rest";
import "@typespec/http";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;
using Azure.ResourceManager;

namespace Microsoft.Widget;

/** Address resource belonging to an employee */
@parentResource(Employee)
model AddressResource is ProxyResource<AddressProperties> {
  ...ResourceNameParameter<AddressResource>;
}

/** Address properties */
model AddressProperties {
  /** Street address line 1 */
  street1?: string;

  /** Street address line 2 */
  street2?: string;

  /** City */
  city?: string;

  /** State or province */
  state?: string;

  /** Postal code */
  postalCode?: string;

  /** Country or region */
  country?: string;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

@armResourceOperations
interface Addresses {
  get is ArmResourceRead<AddressResource>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<AddressResource>;
  update is ArmResourcePatchSync<AddressResource, AddressProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<AddressResource>;
  listByParent is ArmResourceListByParent<AddressResource>;
}
```

## Verify Plan
1. A new file should be created for the Address resource definition.
2. The AddressResource model should be defined as a proxy resource with a parent-child relationship to the Employee resource.
3. The Address properties model should include street address fields, city, state, postal code, country, and a read-only provisioning state.
4. The Addresses interface should include standard CRUD operations and a list-by-parent operation.

## Case reference

[Defining Child Resouce Types](https://azure.github.io/typespec-azure/docs/getstarted/azure-resource-manager/step03/)
[ARM Resource Terminology](https://armwiki.azurewebsites.net/introduction/concepts/resources.html#resource-terminology)