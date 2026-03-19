# CASE 002005-ARM-define-the-resource

An ARM resource provider is composed of resources. There are three essential components of a resource defined with TypeSpec:
- A model type representing the resource
- A model type defining the properties of the resource type
- An interface that defines the operations that can be performed on the resource type, usually a combination of recommended and required operations and resource actions

## Prompt

Define a Azure resource "Employee" under the namespace "Microsoft.Widget" using TypeSpec. Ensure the definition meets TypeSpec Azure design guidelines.

### Input context

<https://github.com/haolingdong-msft/innerloop-typespec-authoring-benchmark/tree/main/cases/ARMTemplate/002005-ARM-define-the-resource/tsp/main.tsp>
properties: age: integer, optional; city: string, optional;profile: bytes, optional;provisioningState: enum, optional;

## Expected response

import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.Core;
using Azure.ResourceManager;

namespace Microsoft.Widget;

/**
 * Provisioning state of the Employee resource.
 * Includes standard ARM terminal states via ResourceProvisioningState
 * plus a custom in-progress state.
 */
@lroStatus
union ProvisioningState {
  ResourceProvisioningState,

  /** The resource is being provisioned. */
  Provisioning: "Provisioning",
}

/** Employee resource properties. */
model EmployeeProperties {
  /** Age of employee. */
  age?: int32;

  /** City of employee. */
  city?: string;

  /** Profile of employee. */
  @encode("base64url")
  profile?: bytes;

  /** The status of the last operation. */
  @visibility(Lifecycle.Read)
  provisioningState?: ProvisioningState;
}

/** An Employee resource. */
model Employee is TrackedResource<EmployeeProperties> {
  ...ResourceNameParameter<Employee>;
}

/** Employee resource operations. */
@armResourceOperations
interface Employees {
  /** Get an Employee resource. */
  get is ArmResourceRead<Employee>;

  /** Create or update an Employee resource. */
  createOrUpdate is ArmResourceCreateOrReplaceAsync<Employee>;

  /** Update an Employee resource. */
  update is ArmCustomPatchSync<
    Employee,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<
      Employee,
      EmployeeProperties
    >
  >;

  /** Delete an Employee resource. */
  delete is ArmResourceDeleteSync<Employee>;

  /** List Employee resources by resource group. */
  listByResourceGroup is ArmResourceListByParent<Employee>;

  /** List Employee resources by subscription. */
  listBySubscription is ArmListBySubscription<Employee>;
}
```

## Verify Plan
1. A new file should be created for the Employee resource definition.
2. The Employee model should be defined as a tracked resource under the Microsoft.Widget namespace.
3. The Employee properties model should include age, city, profile, and a read-only provisioning state.
4. A provisioning state union type should be defined with standard ARM states plus custom states.
5. The Employees interface should include standard CRUD operations and list operations by both resource group and subscription.

## Case reference

[Defining an Azure Resource](https://armwiki.azurewebsites.net/introduction/concepts/resources.html)
[Defining the resource with Typespec](https://azure.github.io/typespec-azure/docs/getstarted/azure-resource-manager/step02/)
[ARM Resource Types](https://azure.github.io/typespec-azure/docs/howtos/arm/resource-type/)
