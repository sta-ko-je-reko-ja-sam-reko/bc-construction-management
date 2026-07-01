namespace Construction.Subcontracts;

interface "CONS IChangeOrderHeader"
{
    Access = Public;

    /// <summary>Assigns the number on insert.</summary>
    procedure Trigger_OnInsert(var ChangeOrderHeader: Record "CONS Change Order Header");

    /// <summary>Cascades deletion to the change order lines.</summary>
    procedure Trigger_OnDelete(var ChangeOrderHeader: Record "CONS Change Order Header");

    /// <summary>
    /// Applies an approved change order: owner changes raise the project contract value, subcontract
    /// changes add variation lines to the subcontract, and the lines push to the project budget.
    /// </summary>
    procedure Apply(var ChangeOrderHeader: Record "CONS Change Order Header");
}
