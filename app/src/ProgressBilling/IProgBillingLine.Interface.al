namespace Construction.ProgressBilling;

interface "CONS IProgBillingLine"
{
    Access = Public;

    /// <summary>Inherits the retention % from the header on insert.</summary>
    procedure Trigger_OnInsert(var ProgBillingLine: Record "CONS Progress Billing Line");

    /// <summary>Recomputes completed-to-date, % complete, retention and net due for the line.</summary>
    procedure Validate_Amounts(var ProgBillingLine: Record "CONS Progress Billing Line");
}
