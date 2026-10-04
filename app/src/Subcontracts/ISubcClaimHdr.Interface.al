namespace Construction.Subcontracts;

interface "CONS ISubcClaimHdr"
{
    Access = Public;

    /// <summary>Assigns the number and sequential claim number on insert.</summary>
    procedure Trigger_OnInsert(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Cascades deletion to the claim lines.</summary>
    procedure Trigger_OnDelete(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Certifies an open claim, which locks its lines and allows it to be invoiced.</summary>
    procedure Certify(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Returns a certified claim to Open so its lines can be changed again. Invoiced claims cannot be reopened.</summary>
    procedure Reopen(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Copies vendor/project/retention from the subcontract when it is chosen.</summary>
    procedure Validate_SubcontractNo(var SubcClaimHeader: Record "CONS Subc Claim Header"; xSubcClaimHeader: Record "CONS Subc Claim Header");
}
