namespace Construction.Subcontracts;

using Construction.Core;

page 50291 "CONS Subc Claim Line API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'subcontractClaimLine';
    EntitySetName = 'subcontractClaimLines';
    EntityCaption = 'Subcontract Claim Line';
    EntitySetCaption = 'Subcontract Claim Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Subc Claim Line";
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
                field(subcontractLineNo; Rec."Subcontract Line No.") { Caption = 'Subcontract Line No.'; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(scheduledValue; Rec."Scheduled Value") { Caption = 'Scheduled Value'; }
                field(previousAmount; Rec."Previous Amount") { Caption = 'Previous Amount'; }
                field(thisPeriodAmount; Rec."This Period Amount") { Caption = 'This Period Amount'; }
                field(completedToDate; Rec."Completed To Date") { Caption = 'Completed To Date'; Editable = false; }
                field(percentComplete; Rec."% Complete") { Caption = '% Complete'; Editable = false; }
                field(retentionPct; Rec."Retention %") { Caption = 'Retention %'; }
                field(retentionThisPeriod; Rec."Retention This Period") { Caption = 'Retention This Period'; Editable = false; }
                field(netPayableThisPeriod; Rec."Net Payable This Period") { Caption = 'Net Payable This Period'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Subcontracts);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Subcontracts);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Subcontracts);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
