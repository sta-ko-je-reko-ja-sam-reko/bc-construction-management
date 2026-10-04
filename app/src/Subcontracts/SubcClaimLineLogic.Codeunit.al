namespace Construction.Subcontracts;

using Construction.Retention;

codeunit 60259 "CONS Subc Claim Line Logic" implements "CONS ISubcClaimLine"
{
    Access = Public;

    procedure Trigger_OnInsert(var SubcClaimLine: Record "CONS Subc Claim Line")
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
    begin
        CheckClaimOpen(SubcClaimLine);
        if SubcClaimLine."Retention %" <> 0 then
            exit;
        if SubcClaimHeader.Get(SubcClaimLine."Document No.") then begin
            SubcClaimLine."Retention %" := SubcClaimHeader."Retention %";
            Validate_Amounts(SubcClaimLine);
        end;
    end;

    procedure Trigger_OnModify(var SubcClaimLine: Record "CONS Subc Claim Line")
    begin
        CheckClaimOpen(SubcClaimLine);
    end;

    procedure Trigger_OnDelete(var SubcClaimLine: Record "CONS Subc Claim Line")
    begin
        CheckClaimOpen(SubcClaimLine);
    end;

    /// <summary>Lines of a certified or invoiced claim are locked; reopen the claim to change them.</summary>
    local procedure CheckClaimOpen(SubcClaimLine: Record "CONS Subc Claim Line")
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
    begin
        SubcClaimHeader.SetLoadFields(Status);
        if not SubcClaimHeader.Get(SubcClaimLine."Document No.") then
            exit;
        if SubcClaimHeader.Status <> SubcClaimHeader.Status::Open then
            Error(ClaimLockedErr, SubcClaimHeader."No.", SubcClaimHeader.Status);
    end;

    procedure Validate_Amounts(var SubcClaimLine: Record "CONS Subc Claim Line")
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
    begin
        SubcClaimLine."Completed To Date" := SubcClaimLine."Previous Amount" + SubcClaimLine."This Period Amount";

        if SubcClaimLine."Scheduled Value" <> 0 then
            SubcClaimLine."% Complete" := Round(SubcClaimLine."Completed To Date" / SubcClaimLine."Scheduled Value" * 100, 0.01)
        else
            SubcClaimLine."% Complete" := 0;

        SubcClaimLine."Retention This Period" := RetentionMgt.CalcRetention(SubcClaimLine."This Period Amount", SubcClaimLine."Retention %");
        SubcClaimLine."Net Payable This Period" := SubcClaimLine."This Period Amount" - SubcClaimLine."Retention This Period";
    end;

    var
        ClaimLockedErr: Label 'Subcontractor claim %1 is %2, so its lines cannot be changed. Reopen the claim first.', Comment = '%1 = claim no., %2 = status';
}
