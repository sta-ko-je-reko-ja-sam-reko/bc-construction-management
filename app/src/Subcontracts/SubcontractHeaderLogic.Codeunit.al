namespace Construction.Subcontracts;

using Construction.Setup;
using Microsoft.Foundation.NoSeries;

codeunit 50256 "CONS Subcontract Header Logic" implements "CONS ISubcontractHeader"
{
    Access = Public;

    procedure Trigger_OnInsert(var SubcontractHeader: Record "CONS Subcontract Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if SubcontractHeader."No." <> '' then
            exit;
        ConstructionSetup.Get();
        ConstructionSetup.TestField("Subcontract Nos.");
        SubcontractHeader."No. Series" := ConstructionSetup."Subcontract Nos.";
        SubcontractHeader."No." := NoSeries.GetNextNo(SubcontractHeader."No. Series");
    end;

    procedure Trigger_OnDelete(var SubcontractHeader: Record "CONS Subcontract Header")
    var
        SubcontractLine: Record "CONS Subcontract Line";
    begin
        SubcontractLine.SetRange("Document No.", SubcontractHeader."No.");
        SubcontractLine.DeleteAll(true);
    end;

    procedure Validate_VendorNo(var SubcontractHeader: Record "CONS Subcontract Header"; xSubcontractHeader: Record "CONS Subcontract Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        if SubcontractHeader."Buy-from Vendor No." = xSubcontractHeader."Buy-from Vendor No." then
            exit;
        if SubcontractHeader."Retention %" <> 0 then
            exit;
        if ConstructionSetup.Get() then
            SubcontractHeader."Retention %" := ConstructionSetup."Default Retention %";
    end;
}
