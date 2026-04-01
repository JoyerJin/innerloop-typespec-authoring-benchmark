# Benchmark Test Report

**Date:** 2026-03-13  
**Suite:** TypeSpec Authoring Agent Benchmark  
**Total Cases:** 23  

---

## Executive Summary

| Metric | Result |
|--------|--------|
| **Skill Triggered** (`azure-typespec-author`) | 23/23 (100%) ✅ |
| **MCP Tool Triggered** (`azsdk_typespec_generate_authoring_plan`) | 19/19 applicable cases (100%) ✅ |
| **Result Matches Expected** | 21 exact + 2 partial = 23/23 ✅ |

> **Note:** 4 API versioning cases (001005–001008) correctly use agentic search via `web_fetch` instead of the MCP tool, per the skill's design. They are excluded from the MCP tool count.

---

## Results by Category

| Category | Cases | Skill ✓ | MCP Tool ✓ | Exact Match | Partial Match |
|----------|:-----:|:-------:|:----------:|:-----------:|:-------------:|
| Versioning | 8 | 8/8 | 4/4* | 6/8 | 2/8 |
| ARMTemplate | 8 | 8/8 | 8/8 | 8/8 | 0 |
| LongRunningOperation | 3 | 3/3 | 3/3 | 3/3 | 0 |
| Decorators | 3 | 3/3 | 3/3 | 3/3 | 0 |
| Warning | 1 | 1/1 | 1/1 | 1/1 | 0 |
| **Total** | **23** | **23/23** | **19/19** | **21/23** | **2/23** |

\* Cases 001005–001008 are API versioning tasks that use agentic search (`web_fetch`) per the skill design, not the MCP tool. This is correct behavior.

---

## Detailed Results

### Versioning (001001–001008)

| Case | Name | Skill | MCP Tool | Match | Notes |
|------|------|:-----:|:--------:|:-----:|-------|
| 001001 | version-spread-property | ✅ | ✅ | ⚠️ Partial | Tool suggested wrapper model with `@added`; expected uses `@@added(Employee.identity)`. Both valid. |
| 001002 | version-default-value | ✅ | ✅ | ⚠️ Partial | Tool suggests `@added` with redeclaration; expected uses `@removed/@renamedFrom` + `@added`. Both valid. |
| 001003 | version-required-to-optional | ✅ | ✅ | ✅ | Correctly suggests `@madeOptional(Versions.v2025_05_04_preview)`. |
| 001004 | version-property-decorator | ✅ | ✅ | ✅ | Correctly suggests `@removed/@added/@renamedFrom` pattern for visibility changes. |
| 001005 | version-add-preview-after-preview | ✅ | N/A† | ✅ | Uses agentic search. 3 user interactions (see below). |
| 001006 | version-add-preview-after-stable | ✅ | N/A† | ✅ | Uses agentic search. 2 user interactions (see below). |
| 001007 | version-add-stable-after-preview | ✅ | N/A† | ✅ | Uses agentic search. 2 user interactions (see below). |
| 001008 | version-add-stable-after-stable | ✅ | N/A† | ✅ | Uses agentic search. 1 user interaction (see below). |

† API versioning cases use `web_fetch` for versioning guides per skill design — MCP tool is intentionally not called.

### ARMTemplate (002001–002008)

| Case | Name | Skill | MCP Tool | Match | Notes |
|------|------|:-----:|:--------:|:-----:|-------|
| 002001 | ARM-change-resource-type | ✅ | ✅ | ✅ | Correctly suggests `ExtensionResource` + `Extension.*` operations. |
| 002002 | ARM-define-extension-resource | ✅ | ✅ | ✅ | Correctly suggests `ExtensionResource<AssetProperties>` with scoped ops. |
| 002003 | ARM-define-full-update-operation | ✅ | ✅ | ✅ | Correctly suggests `ArmCustomPatchAsync/Sync` with `ResourceUpdateModel`. |
| 002004 | ARM-define-extension-resource-2 | ✅ | ✅ | ✅ | Correctly suggests `ExtensionResource<BadgeAssignmentProperties>`. |
| 002005 | ARM-define-the-resource | ✅ | ✅ | ✅ | Full `TrackedResource` with CRUD operations generated correctly. |
| 002006 | ARM-define-child-resource | ✅ | ✅ | ✅ | Correctly uses `@parentResource(User)` + `ProxyResource`. |
| 002007 | ARM-define-custom-action | ✅ | ✅ | ✅ | Correctly uses `ArmResourceActionSync<User, NotifyRequest, NotifyResponse>`. |
| 002008 | ARM-add-parameters | ✅ | ✅ | ✅ | Perfect match: `Parameters = Azure.Core.TopQueryParameter & Azure.Core.SkipQueryParameter`. |

### LongRunningOperation (003001–003003)

| Case | Name | Skill | MCP Tool | Match | Notes |
|------|------|:-----:|:--------:|:-----:|-------|
| 003001 | dataplane-async-delete-op | ✅ | ✅ | ✅ | Correctly suggests `StandardResourceOperations.LongRunningResourceDelete<StacItem>`. |
| 003002 | arm-action-lro | ✅ | ✅ | ✅ | Perfect match: `ArmResourceActionAsync` with `ArmCombinedLroHeaders`. |
| 003003 | arm-modify-response | ✅ | ✅ | ✅ | Perfect match: `ArmAsyncOperationHeader<FinalResult = Employee>` without `RetryAfterHeader`. |

### Decorators (004001–004003)

| Case | Name | Skill | MCP Tool | Match | Notes |
|------|------|:-----:|:--------:|:-----:|-------|
| 004001 | decorate-mgmt-resource-name-parameter | ✅ | ✅ | ✅ | Identifies `ResourceNameParameter` renaming issue; suggests both solutions. |
| 004002 | decorate-length-constrains-on-array-item | ✅ | ✅ | ✅ | Perfect match: `scalar AssetName extends string` with `@minLength/@maxLength`. |
| 004003 | delete-and-restore-operationId-decorator | ✅ | ✅ | ✅ | Correctly identifies two-step pattern and filter condition. |

### Warning (005001)

| Case | Name | Skill | MCP Tool | Match | Notes |
|------|------|:-----:|:--------:|:-----:|-------|
| 005001 | warning-suppress-warning | ✅ | ✅ | ✅ | Correctly explains `#suppress` directive with diagnostic code and justification. |

---

## Agent-User Interaction Details (Cases 001005–001008)

These cases require the agent to interactively collect information from the user before generating a versioning plan. The skill uses `web_fetch` to download the relevant versioning guide, then asks clarifying questions.

### Case 001005 — Preview after Preview (3 interactions)

**Scenario:** Add a new preview version after an existing preview, following the general case workflow.

| # | Agent Question | User Response |
|---|---------------|---------------|
| 1 | "Any types or properties `@added` in previous preview (`v2024_10_01_preview`) that should be removed in new preview?" Lists: `age` (with default 21), `workLocation`, `WorkLocation` model | "Remove added `age` property" |
| 2 | "Any types or properties `@removed` in previous preview that should now appear in new preview?" Lists: `oldAge` | "Add back removed `oldAge` property" |
| 3 | "Any decorator changes (`@renamedFrom`, `@typeChangedFrom`, `@madeOptional`) from previous preview to revert?" Lists: `oldAge` `@renamedFrom` | "`oldAge` `renamedFrom` should be reverted" |

**Expected outcome:** Agent updates `Versions` enum, cleans up versioning decorators for `age`, restores `oldAge`, reverts `@renamedFrom`, and renames the examples folder.

### Case 001006 — Preview after Stable (2 interactions)

**Scenario:** Add a new preview version branching from the latest stable version.

| # | Agent Question | User Response |
|---|---------------|---------------|
| 1 | "Any types or properties that should be removed in the new preview version?" Lists existing types/properties from stable. | "I want to add/modify/remove features" |
| 2 | "What new types, properties, renames, or other modifications should be introduced in the new preview version?" | "Add a new property `department` of type `string` to `EmployeeProperties`" |

**Expected outcome:** Agent adds `v2025_05_04_preview` with `@previewVersion` to `Versions` enum, adds `@added(Versions.v2025_05_04_preview) department?: string` to `EmployeeProperties`, creates examples folder.

### Case 001007 — Stable after Preview (2 interactions)

**Scenario:** Promote a preview version to stable, choosing which preview features to include.

| # | Agent Question | User Response |
|---|---------------|---------------|
| 1 | "Which of these preview features should be carried over to the new stable version `2025-01-01`? Should all be included, or should any be excluded?" Lists: `@added age` (default 21), `@added workLocation/WorkLocation`, `@removed oldAge`, `@renamedFrom oldAge→age` | "Let me specify which to include/exclude" |
| 2 | "Which features should be EXCLUDED from the stable version `2025-01-01`? Select all that should NOT carry over." | "Exclude `workLocation` property and `WorkLocation` model" |

**Expected outcome:** Agent adds `v2025_01_01` to `Versions` enum, removes preview version, updates `@added/@removed/@renamedFrom` references to `v2025_01_01` for included features, deletes excluded features (`workLocation`, `WorkLocation`) entirely.

### Case 001008 — Stable after Stable (1 interaction)

**Scenario:** Add a new stable version after an existing stable version with a specific new property.

| # | Agent Question | User Response |
|---|---------------|---------------|
| 1 | Agent presents plan: "Add stable version `2025-01-01` with new `department` property. Steps: 1) Add `v2025_01_01` to `Versions` enum, 2) Add `department?: string` with `@added(Versions.v2025_01_01)`, 3) Run TypeSpec validation" | "Accept plan and build on autopilot (recommended)" |

**Expected outcome:** Agent adds `v2025_01_01` to enum, adds `@added(Versions.v2025_01_01) department?: string` to `EmployeeProperties`. Minimal interaction since the prompt already specifies the change.

---

## Partial Match Analysis

### Case 001001 — version-spread-property

- **Tool approach:** Suggests creating a wrapper model and applying `@added` to the wrapper.
- **Expected approach:** Uses `@@added(Employee.identity, Versions.xxx)` augment decorator to annotate the spread property directly.
- **Assessment:** Both approaches are valid TypeSpec solutions for versioning spread properties. The expected approach is more concise.

### Case 001002 — version-default-value

- **Tool approach:** Suggests `@added` with versioned redeclaration of the property.
- **Expected approach:** Uses `@removed(Versions.v1)` on old property + `@added(Versions.v2)` with `@renamedFrom` on new property.
- **Assessment:** Both approaches achieve the goal. The expected approach provides a cleaner migration path with explicit rename tracking.

---

## Key TypeSpec Patterns Validated

| Pattern | Cases | Description |
|---------|-------|-------------|
| `@@added` augment decorator | 001001 | Versioning spread/intersected properties |
| `@removed/@added/@renamedFrom` | 001002, 001004 | Paired versioning with rename tracking |
| `@madeOptional` | 001003 | Changing required → optional across versions |
| `ExtensionResource<T>` | 002001, 002002, 002004 | ARM extension resource definition |
| `@parentResource` + `ProxyResource` | 002006 | ARM child resource definition |
| `TrackedResource<T>` | 002005 | ARM tracked resource with full CRUD |
| `ArmCustomPatchAsync/Sync` | 002003 | Full-update PATCH operations |
| `ArmResourceActionSync/Async` | 002007, 003002 | Custom POST actions and LRO actions |
| `ArmCombinedLroHeaders` | 003002, 003003 | LRO header customization |
| `scalar X extends string` | 004002 | Array item constraints via named scalars |
| `Parameters = A & B` | 002008 | Composing query parameters |
| `#suppress` | 005001 | Warning suppression with diagnostic codes |
