# CASE 002007-ARM-define-custom-action

Some resources will provide more than the standard CRUD operations and will need to define a custom action endpoint. 

## Prompt

Add an additional POST action called "/notify" to the standard operations of Employee. Ensure the definition meets TypeSpec Azure design guidelines.

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

Additional resource operations can be added to the interface where you defined standard resource operations, using the ArmResourceAction templates.

```tsp
union NotificationPriority {
  string,

  /** Low priority */
  Low: "Low",

  /** Normal priority */
  Normal: "Normal",

  /** High priority */
  High: "High",

  /** Critical priority */
  Critical: "Critical",
}

/** The details of an employee notification. */
model NotificationRequest {
  /** The notification message. */
  message: string;

  /** The priority of the notification. */
  priority: NotificationPriority;
}

/** The result of a notification operation. */
model NotificationResponse {
  /** The unique identifier of the notification. */
  notificationId: string;

  /** The status of the notification. */
  status: string;
}

@armResourceOperations
interface Employees {
	get is ArmResourceRead<Employee>;
	createOrUpdate is ArmResourceCreateOrReplaceAsync<Employee>;
	update is ArmResourcePatchSync<Employee, EmployeeProperties>;
	delete is ArmResourceDeleteWithoutOkAsync<Employee>;
	listByResourceGroup is ArmResourceListByParent<Employee>;
	listBySubscription is ArmListBySubscription<Employee>;
	notify is ArmResourceActionSync<Employee, NotifyRequest, NotifyResponse>;
}
```

## Verify Plan
1. Add new union NotificationPriority, extensible enum with Low, Normal, High, Critical.
2. Add new model NotificationRequest with properties message: string, priority: NotificationPriority.
3. Add new model NotificationResponse with properties notificationId: string, status: string.
4. Add new operation in Employees interface:
	notify is ArmResourceActionSync<Employee, NotificationRequest, NotificationResponse>;
5. Create example files for both API versions (2021-10-01-preview, 2021-11-01).

## Case reference

[Define Custom Actions](https://azure.github.io/typespec-azure/docs/getstarted/azure-resource-manager/step04/)