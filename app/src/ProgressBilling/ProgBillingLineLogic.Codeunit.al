namespace Construction.ProgressBilling;

using Construction.Retention;

codeunit 50153 "CONS Prog. Billing Line Logic" implements "CONS IProgBillingLine"
{
    Access = Public;

    procedure Trigger_OnInsert(var ProgBillingLine: Record "CONS Progress Billing Line")
    var
        ProgBillingHeader: Record "CONS Progress Billing Header";
    begin
        if ProgBillingLine."Retention %" <> 0 then
            exit;
        if ProgBillingHeader.Get(ProgBillingLine."Document No.") then
            ProgBillingLine."Retention %" := ProgBillingHeader."Retention %";
    end;

    procedure Validate_Amounts(var ProgBillingLine: Record "CONS Progress Billing Line")
    var
        RetentionMgt: Codeunit "CONS Retention Mgt";
        BilledThisPeriod: Decimal;
    begin
        ProgBillingLine."Completed To Date" :=
            ProgBillingLine."Previous Amount" + ProgBillingLine."This Period Amount" + ProgBillingLine."Stored Materials";

        if ProgBillingLine."Scheduled Value" <> 0 then
            ProgBillingLine."% Complete" := Round(ProgBillingLine."Completed To Date" / ProgBillingLine."Scheduled Value" * 100, 0.01)
        else
            ProgBillingLine."% Complete" := 0;

        BilledThisPeriod := ProgBillingLine."This Period Amount" + ProgBillingLine."Stored Materials";
        ProgBillingLine."Retention This Period" := RetentionMgt.CalcRetention(BilledThisPeriod, ProgBillingLine."Retention %");
        ProgBillingLine."Net Due This Period" := BilledThisPeriod - ProgBillingLine."Retention This Period";
    end;
}
