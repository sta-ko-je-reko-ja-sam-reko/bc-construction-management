namespace Construction.ProgressBilling;

interface "CONS IProgBillingHeader"
{
    Access = Public;

    /// <summary>Assigns the number and sequential application number on insert.</summary>
    procedure Trigger_OnInsert(var ProgBillingHeader: Record "CONS Progress Billing Header");

    /// <summary>Defaults the bill-to customer and retention % when the project is chosen.</summary>
    procedure Validate_ProjectNo(var ProgBillingHeader: Record "CONS Progress Billing Header"; xProgBillingHeader: Record "CONS Progress Billing Header");

    /// <summary>Cascades deletion to the application's lines.</summary>
    procedure Trigger_OnDelete(var ProgBillingHeader: Record "CONS Progress Billing Header");
}
