import "@typespec/rest";
import "@typespec/http";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;
using Azure.ResourceManager;

namespace Microsoft.Contoso;

/** User resource */
model User is TrackedResource<UserProperties> {
  ...ResourceNameParameter<User>;
}

/** User properties */
model UserProperties {
  /** Display name of the user */
  displayName?: string;

  /** Email address of the user */
  email?: string;

  /** Roles assigned to the user */
  roles?: string[];

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
interface Users {
  get is ArmResourceRead<User>;
  createOrUpdate is ArmResourceCreateOrReplaceAsync<User>;
  update is ArmResourcePatchSync<User, UserProperties>;
  delete is ArmResourceDeleteWithoutOkAsync<User>;
  listByResourceGroup is ArmResourceListByParent<User>;
  listBySubscription is ArmListBySubscription<User>;
}
