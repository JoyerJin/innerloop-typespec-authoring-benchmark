# CASE 002004-ARM-define-extension-resource

## Prompt

Define a "badge assignment" extension resource. It should be an extension resource that can be attached to an employee. Ensure the definition meets TypeSpec Azure guidelines.

### Input context

<https://github.com/Azure/azure-rest-api-specs-pr/pull/25670>
<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/tree/main/cases/ARMTemplate/002004-ARM-define-extension-resource/tsp/badgeAssignment.tsp>

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

/** Badge assignment extension resource */
model BadgeAssignment is ProxyResource<BadgeAssignmentProperties> {
  ...ResourceNameParameter<BadgeAssignment>;
}

/** Badge assignment properties */
model BadgeAssignmentProperties {
  /** Identifier of the badge. */
  badgeId: string;

  /** The date when the badge was assigned. */
  assignedDate?: plainDate;

  /** Indicates whether the badge assignment is active. */
  isActive?: boolean;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

@armResourceOperations
interface BadgeAssignments {
  get is ArmResourceRead<BadgeAssignment>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<BadgeAssignment>;
  update is ArmResourcePatchSync<BadgeAssignment, BadgeAssignmentProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<BadgeAssignment>;
  listByParent is ArmResourceListByParent<BadgeAssignment>;
}
```

## Expected response

```tsp
import "@azure-tools/typespec-azure-resource-manager";

using Azure.ResourceManager;

namespace Microsoft.Widget;

/** Badge assignment properties. */
model BadgeAssignmentProperties {
  /** The unique identifier of the badge. */
  badgeId: string;

  /** The date the badge was assigned. */
  assignedDate?: plainDate;

  /** Indicates whether the badge assignment is currently active. */
  isActive?: boolean;

  /** The status of the last provisioning operation performed on the badge assignment. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** A badge assignment extension resource attached to an employee. */
model BadgeAssignment is ExtensionResource<BadgeAssignmentProperties> {
  ...ResourceNameParameter<BadgeAssignment>;
}

/** Badge assignment operations scoped to a target resource. */
interface BadgeAssignmentOps<Scope extends Azure.ResourceManager.Foundations.SimpleResource> {
  /** Get a badge assignment. */
  get is Azure.ResourceManager.Extension.Read<Scope, BadgeAssignment>;
  /** Create or update a badge assignment. */
  createOrUpdate is Azure.ResourceManager.Extension.CreateOrReplaceAsync<Scope, BadgeAssignment>;
  /** Update a badge assignment. */
  update is Azure.ResourceManager.Extension.CustomPatchAsync<Scope, BadgeAssignment>;
  /** Delete a badge assignment. */
  delete is Azure.ResourceManager.Extension.DeleteWithoutOkAsync<Scope, BadgeAssignment>;
  /** List badge assignments by target resource. */
  list is Azure.ResourceManager.Extension.ListByTarget<Scope, BadgeAssignment>;
}

/** Badge assignment operations on employee resources. */
@armResourceOperations
interface EmployeeBadgeAssignments extends BadgeAssignmentOps<Employee> {}
```

## Verify Plan
1. Define BadgeAssignment as a proper ARM extension resource attached to Employee.
2. Replaced ArmResource* with Extension.* templates (Read, CreateOrReplaceAsync, CustomPatchAsync, DeleteWithoutOkAsync, ListByTarget) scoped to Employee.
3. Interface pattern: Generic BadgeAssignmentOps<Scope> bound to Employee via @armResourceOperations interface EmployeeBadgeAssignments extends BadgeAssignmentOps<Employee>.
4. Properties are unchanged.

## Case reference

[ARM Resource Types - Choosing a Resource Type](https://azure.github.io/typespec-azure/docs/howtos/arm/resource-type/#choosing-a-resource-type)