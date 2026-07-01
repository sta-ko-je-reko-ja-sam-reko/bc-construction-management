namespace Construction.Subcontracts;

using Construction.Setup;
using Microsoft.Foundation.NoSeries;

codeunit 50258 "CONS Subc Claim Hdr Logic" implements "CONS ISubcClaimHdr"
{
    Access = Public;

    procedure Trigger_OnInsert(var SubcClaimHeader: Record "CONS Subc Claim Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if SubcClaimHeader."No." = '' then begin
            ConstructionSetup.Get();
            ConstructionSetup.TestField("Subcontract Claim Nos.");
            SubcClaimHeader."No. Series" := ConstructionSetup."Subcontract Claim Nos.";
            SubcClaimHeader."No." := NoSeries.GetNextNo(SubcClaimHeader."No. Series");
        end;
        if (SubcClaimHeader."Claim No." = 0) and (SubcClaimHeader."Subcontract No." <> '') then
            SubcClaimHeader."Claim No." := NextClaimNo(SubcClaimHeader."Subcontract No.");
    end;

    procedure Trigger_OnDelete(var SubcClaimHeader: Record "CONS Subc Claim Header")
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.SetRange("Document No.", SubcClaimHeader."No.");
        SubcClaimLine.DeleteAll(true);
    end;

    procedure Validate_SubcontractNo(var SubcClaimHeader: Record "CONS Subc Claim Header"; xSubcClaimHeader: Record "CONS Subc Claim Header")
    var
        SubcontractHeader: Record "CONS Subcontract Header";
    begin
        if SubcClaimHeader."Subcontract No." = xSubcClaimHeader."Subcontract No." then
            exit;
        if SubcClaimHeader."Subcontract No." = '' then
            exit;
        if not SubcontractHeader.Get(SubcClaimHeader."Subcontract No.") then
            exit;
        SubcClaimHeader."Project No." := SubcontractHeader."Project No.";
        SubcClaimHeader."Buy-from Vendor No." := SubcontractHeader."Buy-from Vendor No.";
        if SubcClaimHeader."Retention %" = 0 then
            SubcClaimHeader."Retention %" := SubcontractHeader."Retention %";
    end;

    local procedure NextClaimNo(SubcontractNo: Code[20]): Integer
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
    begin
        SubcClaimHeader.SetCurrentKey("Subcontract No.", "Claim No.");
        SubcClaimHeader.SetRange("Subcontract No.", SubcontractNo);
        if SubcClaimHeader.FindLast() then
            exit(SubcClaimHeader."Claim No." + 1);
        exit(1);
    end;
}
