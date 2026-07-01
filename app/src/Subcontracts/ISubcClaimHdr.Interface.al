namespace Construction.Subcontracts;

interface "CONS ISubcClaimHdr"
{
    Access = Public;

    /// <summary>Assigns the number and sequential claim number on insert.</summary>
    procedure Trigger_OnInsert(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Cascades deletion to the claim lines.</summary>
    procedure Trigger_OnDelete(var SubcClaimHeader: Record "CONS Subc Claim Header");

    /// <summary>Copies vendor/project/retention from the subcontract when it is chosen.</summary>
    procedure Validate_SubcontractNo(var SubcClaimHeader: Record "CONS Subc Claim Header"; xSubcClaimHeader: Record "CONS Subc Claim Header");
}
