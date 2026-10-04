namespace Construction.Subcontracts;

using Construction.Core;

codeunit 60266 "CONS Subc Claim Seed"
{
    Access = Public;

    /// <summary>
    /// Seeds claim lines on the claim from the subcontract's scope lines. Idempotent: a scope line
    /// already represented (by Subcontract Line No.) is skipped.
    /// </summary>
    /// <param name="SubcClaimHeader">The claim to seed lines onto.</param>
    internal procedure SeedFromSubcontract(var SubcClaimHeader: Record "CONS Subc Claim Header")
    var
        SubcontractLine: Record "CONS Subcontract Line";
        LicenseMgt: Codeunit "CONS License Mgt.";
        Created: Integer;
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
        SubcClaimHeader.TestField("Subcontract No.");

        SubcontractLine.SetRange("Document No.", SubcClaimHeader."Subcontract No.");
        if SubcontractLine.FindSet() then
            repeat
                if not LineExists(SubcClaimHeader."No.", SubcontractLine."Line No.") then begin
                    InsertLine(SubcClaimHeader, SubcontractLine);
                    Created += 1;
                end;
            until SubcontractLine.Next() = 0;

        if Created = 0 then
            Message(NothingToSeedMsg)
        else
            Message(SeededMsg, Created);
    end;

    local procedure LineExists(DocumentNo: Code[20]; SubcontractLineNo: Integer): Boolean
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.SetRange("Document No.", DocumentNo);
        SubcClaimLine.SetRange("Subcontract Line No.", SubcontractLineNo);
        exit(not SubcClaimLine.IsEmpty());
    end;

    local procedure InsertLine(SubcClaimHeader: Record "CONS Subc Claim Header"; SubcontractLine: Record "CONS Subcontract Line")
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.Init();
        SubcClaimLine."Document No." := SubcClaimHeader."No.";
        SubcClaimLine."Line No." := NextLineNo(SubcClaimHeader."No.");
        SubcClaimLine."Subcontract Line No." := SubcontractLine."Line No.";
        SubcClaimLine."Job Task No." := SubcontractLine."Job Task No.";
        SubcClaimLine.Description := SubcontractLine.Description;
        SubcClaimLine."Retention %" := SubcClaimHeader."Retention %";
        SubcClaimLine.Validate("Scheduled Value", SubcontractLine."Line Amount");
        SubcClaimLine.Validate("Previous Amount", PreviousCompletedToDate(SubcClaimHeader, SubcontractLine."Line No."));
        SubcClaimLine.Insert(true);
    end;

    /// <summary>
    /// Returns the value completed to date on the same subcontract line in the latest earlier claim of the subcontract that
    /// has been certified or invoiced (draft claims do not count). That cumulative value is this claim's "previous" amount,
    /// so each claim only pays the work done since the last certified one.
    /// </summary>
    local procedure PreviousCompletedToDate(SubcClaimHeader: Record "CONS Subc Claim Header"; SubcontractLineNo: Integer): Decimal
    var
        PriorHeader: Record "CONS Subc Claim Header";
        PriorLine: Record "CONS Subc Claim Line";
    begin
        if SubcClaimHeader."Claim No." <= 1 then
            exit(0);
        PriorHeader.SetCurrentKey("Subcontract No.", "Claim No.");
        PriorHeader.SetRange("Subcontract No.", SubcClaimHeader."Subcontract No.");
        PriorHeader.SetRange("Claim No.", 1, SubcClaimHeader."Claim No." - 1);
        PriorHeader.SetFilter(Status, '<>%1', PriorHeader.Status::Open);
        PriorHeader.SetFilter("No.", '<>%1', SubcClaimHeader."No.");
        PriorHeader.Ascending(false);
        if PriorHeader.FindSet() then
            repeat
                PriorLine.SetRange("Document No.", PriorHeader."No.");
                PriorLine.SetRange("Subcontract Line No.", SubcontractLineNo);
                if PriorLine.FindFirst() then
                    exit(PriorLine."Completed To Date");
            until PriorHeader.Next() = 0;
        exit(0);
    end;

    local procedure NextLineNo(DocumentNo: Code[20]): Integer
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
    begin
        SubcClaimLine.SetRange("Document No.", DocumentNo);
        if SubcClaimLine.FindLast() then
            exit(SubcClaimLine."Line No." + 10000);
        exit(10000);
    end;

    var
        SeededMsg: Label '%1 claim line(s) were created.', Comment = '%1 = count';
        NothingToSeedMsg: Label 'There are no subcontract scope lines to seed (or they are already on this claim).';
}
