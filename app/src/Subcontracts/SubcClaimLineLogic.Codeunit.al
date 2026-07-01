namespace Construction.Subcontracts;

using Construction.Retention;

codeunit 50259 "CONS Subc Claim Line Logic" implements "CONS ISubcClaimLine"
{
    Access = Public;

    procedure Trigger_OnInsert(var SubcClaimLine: Record "CONS Subc Claim Line")
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
    begin
        if SubcClaimLine."Retention %" <> 0 then
            exit;
        if SubcClaimHeader.Get(SubcClaimLine."Document No.") then
            SubcClaimLine."Retention %" := SubcClaimHeader."Retention %";
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
}
