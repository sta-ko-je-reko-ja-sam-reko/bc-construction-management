namespace Construction.ProgressBilling;

using Construction.Core;

page 50285 "CONS Progress Billing API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'progressBilling';
    EntitySetName = 'progressBillings';
    EntityCaption = 'Progress Billing';
    EntitySetCaption = 'Progress Billings';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Progress Billing Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(applicationNo; Rec."Application No.") { Caption = 'Application No.'; Editable = false; }
                field(periodStart; Rec."Period Start") { Caption = 'Period Start'; }
                field(periodEnd; Rec."Period End") { Caption = 'Period End'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(retentionPct; Rec."Retention %") { Caption = 'Retention %'; }
                field(billToCustomerNo; Rec."Bill-to Customer No.") { Caption = 'Bill-to Customer No.'; }
                field(scheduledValue; Rec."Scheduled Value") { Caption = 'Scheduled Value'; Editable = false; }
                field(thisPeriodAmount; Rec."This Period Amount") { Caption = 'This Period Amount'; Editable = false; }
                field(retentionThisPeriod; Rec."Retention This Period") { Caption = 'Retention This Period'; Editable = false; }
                field(netDueThisPeriod; Rec."Net Due This Period") { Caption = 'Net Due This Period'; Editable = false; }
                field(noSeries; Rec."No. Series") { Caption = 'No. Series'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::ProgressBilling);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::ProgressBilling);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::ProgressBilling);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
