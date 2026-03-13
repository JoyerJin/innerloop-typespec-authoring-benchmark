# innerloop-typespec-authoring-benchmark

A benchmark repository for TypeSpec authoring scenarios and common questions.

## Folder Structure

```
innerloop-typespec-authoring-benchmark/
├── cases/                          # Categorized TypeSpec authoring cases
│   ├── Decorators/                # Questions about TypeSpec decorators usage
│   ├── Operations/                # Questions about API operations definition
│   ├── Paging/                    # Questions about pagination patterns
│   ├── Patch/                     # Questions about PATCH operations
│   ├── Long Running Operation(LRO)/ # Questions about LRO implementation
│   ├── Versioning/                # Questions about API versioning
│   └── Arm Resource Manager(ARM) Template/ # Questions about ARM template selection
└── raw/                           # Raw source materials
    ├── references.md              # Reference documentation
    └── typespec-discussion-channel/ # Discussion channel archives
        └── typespec_*.md          # Weekly discussion snapshots
```

## Case Summary

### Versioning (8 cases)

| Case Code | Case Name | Prompt |
|-----------|-----------|--------|
| 001001 | version-spread-property | I added `...ManagedServiceIdentityProperty` which updates all my existing API versions. I want to introduce the properties of the spread model in a new API version only. |
| 001002 | version-default-value | Add a default value `21` for property age in model EmployeeProperties from api version 2025-11-01. |
| 001003 | version-required-to-optional | Change the property age of EmployeeProperties from required to optional for new api version 2025-05-04-preview. |
| 001004 | version-property-decorator | Change the visibility of property 'provisioningState' from Lifecycle.Read to Lifecycle.Read and Lifecycle.Create in version 2025-05-04-preview only. |
| 001005 | version-add-preview-after-preview | Add a new preview version `2025-05-04-preview` to my service widget resource manager. |
| 001006 | version-add-preview-after-stable | Add a new preview version `2025-05-04-preview` to my service. In this new version, add a new property `department` of type `string` to `EmployeeProperties`. |
| 001007 | version-add-stable-after-preview | Promote my service to stable. Add a new stable version `2025-01-01` to replace the preview version `2024-10-01-preview`. Also add a new property `email` of type `string` to `EmployeeProperties`. |
| 001008 | version-add-stable-after-stable | Add a new stable version `2025-01-01` to my service. Add a new property `department` of type `string` to `EmployeeProperties`. |

### ARM Template (8 cases)

| Case Code | Case Name | Prompt |
|-----------|-----------|--------|
| 002001 | ARM-change-resource-type | Change resource Employee as extension resource. |
| 002002 | ARM-define-extension-resource | Add an extension resource asset. |
| 002003 | ARM-define-full-update-operation | Define a PATCH operation of Employees. It is to update properties of an employee. Ensure the definition meets TypeSpec Azure guidelines. |
| 002004 | ARM-define-extension-resource | Define a "badge assignment" extension resource. It should be an extension resource that can be attached to an employee. Ensure the definition meets TypeSpec Azure guidelines. |
| 002005 | ARM-define-the-resource | Define an Azure resource "User" under the namespace "Microsoft.Contoso" using TypeSpec. Ensure the definition meets TypeSpec Azure design guidelines. |
| 002006 | ARM-define-child-resource | Create a new "AddressResource" child resource under the parent resource "user". Ensure the definition meets TypeSpec Azure design guidelines. |
| 002007 | ARM-define-custom-action | Add an additional POST action called "/notify" to the standard operations of User. Ensure the definition meets TypeSpec Azure design guidelines. |
| 002008 | ARM-add-parameters | Add top and skip query parameters to the ListBySubscription operation in interface employees. |

### Long Running Operation (3 cases)

| Case Code | Case Name | Prompt |
|-----------|-----------|--------|
| 003001 | dataplane-async-delete-op | Add an async delete operation for StacItems. |
| 003002 | arm-action-lro | Add a move async operation to move employee, operation's request is MoveRequest, response is MoveResponse. |
| 003003 | arm-modify-response | Modify the LRO createOrUpdate PUT operation in interface employees so that it returns Azure-AsyncOperation header but NOT Retry-After header in the 201 response. |

### Decorators (3 cases)

| Case Code | Case Name | Prompt |
|-----------|-----------|--------|
| 004001 | decorate-mgmt-resource-name-parameter | Add minLength decorator to set the minLength 1 for resource name parameter of Employee resource. |
| 004002 | decorate-length-constrains-on-array-item | Add @minLength(3) @maxLength(10) constrains for any item of assets array. |
| 004003 | delete-and-restore-operationId-decorator | Remove @operationId and #suppress directives. Then restore those operationIds that do not contain underscores or begin with a lowercase letter. |

### Warning (1 case)

| Case Code | Case Name | Prompt |
|-----------|-----------|--------|
| 005001 | warning-suppress-warning | Add suppressions for the warnings produced by "tsp compile .", and set the justification to "FIXME: Update justification, follow aka.ms/tsp/conversion-fix for details". |

## Write a Test case

use [001001-version-spread-property](./cases/Versioning/001001-version-spread-property) as template to write a Test case.

**Folder structure of a test case**:
```

`<case name>`/
├── case.md                          # Test Case
├── tsp/                             # the typespe code folder
│   ├── main.tsp                
│   ├── ......                       
└── test result/                     # The results for each testing
    ├── <yyyy-mm-result>.md          # result of one test run
    └── ......
```
