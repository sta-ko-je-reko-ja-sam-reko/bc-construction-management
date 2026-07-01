namespace Construction.ProgressBilling;

using Construction.Core;

page 50286 "CONS Progress Billing Line API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'progressBillingLine';
    EntitySetName = 'progressBillingLines';
    EntityCaption = 'Progress Billing Line';
    EntitySetCaption = 'Progress Billing Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Progress Billing Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(documentNo; Rec."Document No.") { Caption = 'Document No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; Editable = false; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(jobPlanningLineNo; Rec."Job Planning Line No.") { Caption = 'Project Planning Line No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(scheduledValue; Rec."Scheduled Value") { Caption = 'Scheduled Value'; }
                field(previousAmount; Rec."Previous Amount") { Caption = 'Previous Amount'; }
                field(thisPeriodAmount; Rec."This Period Amount") { Caption = 'This Period Amount'; }
                field(storedMaterials; Rec."Stored Materials") { Caption = 'Stored Materials'; }
                field(completedToDate; Rec."Completed To Date") { Caption = 'Completed To Date'; Editable = false; }
                field(percentComplete; Rec."% Complete") { Caption = '% Complete'; Editable = false; }
                field(retentionPct; Rec."Retention %") { Caption = 'Retention %'; }
                field(retentionThisPeriod; Rec."Retention This Period") { Caption = 'Retention This Period'; Editable = false; }
                field(netDueThisPeriod; Rec."Net Due This Period") { Caption = 'Net Due This Period'; Editable = false; }
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
