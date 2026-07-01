namespace Construction.Subcontracts;

codeunit 50257 "CONS Subcontract Line Logic" implements "CONS ISubcontractLine"
{
    Access = Public;

    procedure Validate_Amounts(var SubcontractLine: Record "CONS Subcontract Line")
    begin
        SubcontractLine."Line Amount" := Round(SubcontractLine.Quantity * SubcontractLine."Unit Cost");
    end;
}
