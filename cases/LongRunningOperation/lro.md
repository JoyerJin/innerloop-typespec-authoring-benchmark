# LRO 

Guidelines and best practice documents:

Data plane:
Rest api guidelines: https://github.com/microsoft/api-guidelines/blob/vNext/azure/Guidelines.md#delete-lro-pattern
Service behavior (step by step flow): https://github.com/microsoft/api-guidelines/blob/vNext/azure/ConsiderationsForServiceDesign.md#long-running-operations
TypeSpec Authoring: https://azure.github.io/typespec-azure/docs/getstarted/azure-core/step06/

Management plane:
Rest api guidelines: https://github.com/cloud-and-ai-microsoft/resource-provider-contract/blob/master/v1.0/async-api-reference.md
TypeSpec Authoring: https://azure.github.io/typespec-azure/docs/howtos/arm/resource-operations/

## rest api

## service behavior

LRO guideline does not define final get, this is client behavior, LRO guideline only defines long running process. 
examples: https://github.com/Azure/typespec-azure/blob/main/packages/azure-http-specs/specs/azure/resource-manager/operation-templates/lro.tsp

polling from:

Mgmt plane:

PUT: AAO, 

PATCH: AAO

POST: location header

DELETE: AAO

### Put
RPC defines what is the response schema returned by the first PUT.
```json
{
  "location": "Central US",
  "type": "Microsoft.Contoso/widgets",
  "id": "/subscriptions/<subscriptionId>/resourceGroups/myRg/providers/Microsoft.Contoso/widgets/myWidget",
  "tags": {
    "key1": "value 1",
    "key2": "value 2"
  },
  "properties": {
    "provisioningState": "InProgress",
    "comment": "Resource defined structure"
  }
}
```
what is the response return by resource GET
```json
{
  "location": "Central US",
  "type": "Microsoft.Contoso/widgets",
  "id": "/subscriptions/<subscriptionId>/resourceGroups/myRg/providers/Microsoft.Contoso/widgets/myWidget",
  "tags": {
    "key1": "value 1",
    "key2": "value 2"
  },
  "properties": {
    "provisioningState": "InProgress",
    "comment": "Resource defined structure"
  }
}
```

 what is the response schema returned by AAO [here](https://github.com/cloud-and-ai-microsoft/resource-provider-contract/blob/master/v1.0/async-api-reference.md#azure-asyncoperation-resource-format). 
 
 {
  "id": "/subscriptions/id/locations/westus/operationsStatuses/sameguid",
  "name": "sameguid",
  "status" : "RP defined values | Succeeded | Failed | Canceled",
  "startTime": "<DateLiteral per ISO8601>",
  "endTime": "<DateLiteral per ISO8601>",
  "percentComplete": 0.0, // <double between 0 and 100>
  "properties": {
    /* The resource provider can choose the values here, but it should only be
        returned on a successful operation (status being "Succeeded"). */
  },
  "error" : {
    /* RP must return the *code* and *messages* fields. Please use the schema for the "ErrorResponse" Type from the Common Types definition in the Azure Rest API Specifications repository: https://github.com/Azure/azure-rest-api-specs/blob/master/specification/common-types/resource-management/v3/types.json */
    "code": "BadArgument",
    "message": "The provided database 'foo' has an invalid username."
  },
  "operations": [
    {
      "name": "nestedOperation1",
      "status": "Failed",
      "error": {
        "code": "InvalidSku",
        "message": "The sku provided in the request was invalid."
      }
    }
  ]
}


what is the response returned by calling location header url, for location response, only http code matters. example is delete.




## typespec authoring

### Mgmtplane

PUT: ArmResourceCreateOrUpdateAsync

PATCH: ArmCustomPatchAsync

POST: ArmResourceActionAsync

DELETE: ArmResourceDeleteWithoutOkAsync

### Dataplane

PUT: LongRunningResourceCreateOrReplace

PATCH: ArmCustomPatchAsync

POST: ArmResourceActionAsync

DELETE: LongRunningResourceDelete


LRO questions:
1. Polling result schema is not shown in the contract, how to customize it?
1. User should define LRO Headers. It is strange to use combined headers.

https://azure.github.io/typespec-azure/playground/?options=%7B%22linterRuleSet%22%3A%7B%22extends%22%3A%5B%22%40azure-tools%2Ftypespec-azure-rulesets%2Fresource-manager%22%5D%7D%7D&c=aW1wb3J0ICJAdHlwZXNwZWMvaHR0cCI7CtIZcmVzdNUZdmVyc2lvbmluZ8wfYXp1cmUtdG9vbHMvyCstxhVjb3Jl3yvIK3Jlc291cmNlLW1hbmFnZXIiOwoKdXNpbmcgSHR0cDvHDFJlc3TIDFbpAI7IEkHESi5Db3JlzhJSx1xNxls7CgovKiogQ29udG9zb8RUxR4gUHJvdmlkZXIg5gCDbWVudCBBUEkuICovCkBhcm3IIE5hbWVzcGFjZQpAc2VydmljZSgjeyB0aXRsZTogIsdXyC1IdWJDbGllbnQiIH0pCkDnAUNlZCjnAL9zKQpuyFAgTWljcm9zb2Z0LtJG7wC2QVBJIMdNc%2BQAoWVudW3oARNzIHsKICDELjIwMjEtMTAtMDEtcHJldmlld8g1xDQgIOQA10NvbW1vblTkAY%2FHQCj1ATcuyykuyGoudjUpCiAgYNJpYCwKfeYAs0HoALXrAM4g6AHw5ACIbW9kZWwgRW1wbG95ZWUgaXMgVHJhY2tlZOgAgjzIHFByb3BlcnRpZXM%2B5QDkLi7pAKbkAZZQYXJhbWV0ZXLJMT476ACGyV9wyUTSfMpg6QFDQWdlIG9mIGXIP%2BUBOGFnZT86IGludDMyOwrHKUNpdHnSKmNpdHk%2FOiBzdHLlAqnHLFByb2ZpbNNZQGVuY29kZSgiYmFzZTY0dXJsIuQBYHDGMD86IGJ5dGVzyUhUaGUgc3RhdHVzxEt0aGUgbGFzdCDkAMVhdGlvbuUCvCAgQHZpc2liaWxpdHkoTGlmZWN5Y2zkAeBhZMddxCDlA0tTdGF0xGflAavMFOkBSMRzzDLlAIDlAMph6QHVxXdAbHJvxDt1cwp1buQCctFU5QFk5gEaLOwA0shHIGNyZcQncmVxdWVzdCBoYXMgYmVlbiBhY2NlcHRlZMRnICBBxw46ICLICyLWUGnEQOQAtOkAwchE7ACcOiAizA%2FaTHVwZGF0xE%2FFQ1XHDjogIsgLyjvpBGXpAMTmANxk5wGiU3VjY2VlZOUAxckM0z%2FFNuQBTWZhaWzJPkbFDTogIsYJ3Dh3YXMgY2FuY2XKPkPHD%2BQEvccL%2FwFAIGRlbGXpAYBExA3mAPnICyLpA%2F3pA3dtb3bqAcrpA3lNb3ZlUscV6ANyxHNtb3bEaGZyb20gbG9j5gC8xW7EE%2FEDUMszdG%2FPMXRvyi%2F3AJVzcG9uc%2BsEi%2BYAlscW7ACX7gNsxT7FZMZ85gLuzW5pbnRlcmbkBdxP6AOUcyBleHRlbmRz9gaeLsspe30K5wCSVGVyYWZvcm3JHcZs5AGSQdEW6gT%2B5QC95ACICmFsaWFzIExyb0hlYWRlcnMgPesHLy5Gb3Vu5AKz5AXSUmV0cnlBZnRlcsYrICbkA2TlBihiaW5lZMpEPEZpbmFsUmVzdWx0ID3pAVY%2BOwrlBzDoANnqANHrAQ9UZXLmANLlAKNAZG9jKCJFeOQIKHPlAVzKIGNvbmZpZ3XGQ%2BgBe%2BQIOmlmaWVk6QKdKHMpLuUFLEB0YWfITMlGxhp1c2XlALPlBH5WaWEoIuYIfWFzeW5jLekFNsYtcmV0dXLlBu9DaGFuZ2VkRnJvbSgKICAg6QdoLvYG%2BMQjQXJt6ASNTHJv6AJNPMUcICAi6QOZyXXpBNUuIsZCIOsBrsURPiB8IEVycm9yyE4KICDkAKpl7gDr5wIU6AdtQWPEXkHkAOLGfugBp%2F8AqP8AqP8AqEHlAf%2FGTMhxPsYwU2NvcGUgPSBTdWJzY3JpcMRV5gClxRrGJcpTID3OYOQH0g%3D%3D&e=%40azure-tools%2Ftypespec-autorest&vs=%7B%7D

https://github.com/Azure/azure-rest-api-specs/blob/main/specification/terraform/Microsoft.AzureTerraform.Management/routes.tsp#L14

 
what is the expected way to write lro action?  ArmResponse<Employee>

```ts
@armResourceOperations
interface Terraform {
  @doc("Exports the Terraform configuration of the specified resource(s).")
  @tag("ExportTerraform")
  @useFinalStateVia("azure-async-operation")
  @returnTypeChangedFrom(
    Versions.`2021-10-01-preview`,
    ArmAcceptedLroResponse<
      "Resource operation accepted.",
      LroHeaders
    > | ErrorResponse
  )
  exportTerraform is ArmProviderActionAsync<
    Employee,
    ArmAcceptedLroResponse<
      "Resource operation accepted.",
      LroHeaders
    > | ArmResponse<Employee>,
    Scope = SubscriptionActionScope,
    LroHeaders = LroHeaders
  >;
}
```