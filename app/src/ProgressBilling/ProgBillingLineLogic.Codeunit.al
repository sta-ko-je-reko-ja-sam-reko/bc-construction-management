namespace Construction.ProgressBilling;

using Construction.Retention;

codeunit 60153 "CONS Prog. Billing Line Logic" implements "CONS IProgBillingLine"
{
    Access = Public;

    procedure Trigger_OnInsert(var ProgBillingLine: Record "CONS Progress Billing Line")
    var
        ProgBillingHeader: Record "CONS Progress Billing Header";
    begin
        CheckApplicationOpen(ProgBillingLine);
        if ProgBillingLine."Retention %" <> 0 then
            exit;
        if ProgBillingHeader.Get(ProgBillingLine."Document No.") then begin
            ProgBillingLine."Retention %" := ProgBillingHeader."Retention %";
            Validate_Amounts(ProgBillingLine);
        end;
    end;

    procedure Trigger_OnModify(var ProgBillingLine: Record "CONS Progress Billing Line")
    begin
        CheckApplicationOpen(ProgBillingLine);
    end;

    procedure Trigger_OnDelete(var ProgBillingLine: Record "CONS Progress Billing Line")
    begin
        CheckApplicationOpen(ProgBillingLine);
    end;

    /// <summary>Lines of a certified or invoiced application are locked; reopen the application to change them.</summary>
    local procedure CheckApplicationOpen(ProgBillingLine: Record "CONS Progress Billing Line")
    var
        ProgBillingHeader: Record "CONS Progress Billing Header";
    begin
        ProgBillingHeader.SetLoadFields(Status);
        if not ProgBillingHeader.Get(ProgBillingLine."Document No.") then
            exit;
        if ProgBillingHeader.Status <> ProgBillingHeader.Status::Open then
            Error(ApplicationLockedErr, ProgBillingHeader."No.", ProgBillingHeader.Status);
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

    var
        ApplicationLockedErr: Label 'Progress billing application %1 is %2, so its lines cannot be changed. Reopen the application first.', Comment = '%1 = application no., %2 = status';
}
