namespace Construction.Subcontracts;

interface "CONS ISubcClaimLine"
{
    Access = Public;

    /// <summary>Inherits the retention % from the claim header on insert.</summary>
    procedure Trigger_OnInsert(var SubcClaimLine: Record "CONS Subc Claim Line");

    /// <summary>Recomputes completed-to-date, % complete, retention and net payable for the line.</summary>
    procedure Validate_Amounts(var SubcClaimLine: Record "CONS Subc Claim Line");
}
