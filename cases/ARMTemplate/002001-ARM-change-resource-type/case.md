
# CASE 002001-ARM-change-resource-type

## Prompt

change resource Employee as extension resource

### Input context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/tree/main/cases/ARMTemplate/002001-ARM-change-resource-type/tsp/employee.tsp>

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
  update is ArmResourcePatchSync<Employee, EmployeeProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<Employee>;
  listByResourceGroup is ArmResourceListByParent<Employee>;
  listBySubscription is ArmListBySubscription<Employee>;
}
```

## Expected response

1. use the `ExtensionResource<EmployeeProperties>` as their base resource type,

```tsp
model Employee is ExtensionResource<EmployeeProperties> {
  ...ResourceNameParameter<Employee>;
}

interface EmployeeOps<Scope extends Azure.ResourceManager.Foundations.SimpleResource> {
  get is Extension.Read<Scope, Employee>;
  createOrUpdate is Extension.CreateOrReplaceAsync<Scope, Employee>;
  update is Extension.CustomPatchSync<
    Scope,
    Employee,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<
      Employee,
      EmployeeProperties
    >
  >;
  delete is Extension.DeleteWithoutOkAsync<Scope, Employee>;
  list is Extension.ListByTarget<Scope, Employee>;
}

@armResourceOperations
interface Employees extends EmployeeOps<Extension.ScopeParameter> {}
```

## Verify Plan
1. Model Employee changed from TrackedResource<EmployeeProperties> to ExtensionResource<EmployeeProperties>.
2. Replace tracked-resource templates with extension-resource templates:
- ArmResourceRead → Extension.Read
- ArmResourceCreateOrReplaceAsync → Extension.CreateOrReplaceAsync
- ArmResourcePatchSync → Extension.CustomPatchSync
- ArmResourceDeleteWithoutOkAsync → Extension.DeleteWithoutOkAsync
- ArmResourceListByParent + ArmListBySubscription → single Extension.ListByTarget
3. Use a scope-parameterized EmployeeOps<Scope> interface with Employees extends EmployeeOps<Extension.ScopeParameter>.

# Case reference

[Two kinds of extension resource](https://teams.microsoft.com/l/message/19:906c1efbbec54dc8949ac736633e6bdf@thread.skype/1749033874376?tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&groupId=3e17dcb0-4257-4a30-b843-77f47f1d4121&parentMessageId=1749033874376&teamName=Azure%20SDK&channelName=TypeSpec%20Discussion&createdTime=1749033874376)
