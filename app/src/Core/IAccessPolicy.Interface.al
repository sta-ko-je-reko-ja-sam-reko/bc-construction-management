namespace Construction.Core;

/// <summary>
/// The access-policy seam — answers "does the current user effectively have this permission?" by object id,
/// without ever instantiating a licensed product object. Resolved through <c>CONS Service Locator</c> and used
/// by the base-app subscriber proxies (and the feature facade) as their licensing gate, so the effective-
/// permission logic lives in ONE place instead of being copy-pasted into every proxy. Both the default
/// implementation (<c>CONS Access Policy</c>) and the Service Locator that hands it out are in the Unlicensed
/// base permission set, so resolving the check never instantiates a licensed object. Swappable: a test or a
/// dependent app can inject a different policy via the Service Locator's <c>ImplementAccessPolicy</c>.
/// </summary>
interface "CONS IAccessPolicy"
{
    /// <summary>Whether the current user has effective Execute permission on the codeunit (by id).</summary>
    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean;

    /// <summary>Whether the current user has effective Read permission on the table data (by id).</summary>
    procedure HasEffectiveRead(TableId: Integer): Boolean;
}
