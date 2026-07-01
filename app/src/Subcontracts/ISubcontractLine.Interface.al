namespace Construction.Subcontracts;

interface "CONS ISubcontractLine"
{
    Access = Public;

    /// <summary>Recomputes the line amount from quantity and unit cost.</summary>
    procedure Validate_Amounts(var SubcontractLine: Record "CONS Subcontract Line");
}
