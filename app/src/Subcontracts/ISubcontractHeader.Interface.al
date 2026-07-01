namespace Construction.Subcontracts;

interface "CONS ISubcontractHeader"
{
    Access = Public;

    /// <summary>Assigns the number on insert.</summary>
    procedure Trigger_OnInsert(var SubcontractHeader: Record "CONS Subcontract Header");

    /// <summary>Cascades deletion to the subcontract lines.</summary>
    procedure Trigger_OnDelete(var SubcontractHeader: Record "CONS Subcontract Header");

    /// <summary>Defaults the retention % from setup when the vendor is chosen.</summary>
    procedure Validate_VendorNo(var SubcontractHeader: Record "CONS Subcontract Header"; xSubcontractHeader: Record "CONS Subcontract Header");
}
