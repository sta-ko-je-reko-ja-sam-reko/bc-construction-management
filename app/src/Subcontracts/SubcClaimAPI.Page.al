namespace Construction.Subcontracts;

using Construction.Core;

page 50290 "CONS Subc Claim API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'subcontractClaim';
    EntitySetName = 'subcontractClaims';
    EntityCaption = 'Subcontract Claim';
    EntitySetCaption = 'Subcontract Claims';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Subc Claim Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(subcontractNo; Rec."Subcontract No.") { Caption = 'Subcontract No.'; }
                field(claimNo; Rec."Claim No.") { Caption = 'Claim No.'; Editable = false; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; Editable = false; }
                field(buyFromVendorNo; Rec."Buy-from Vendor No.") { Caption = 'Subcontractor No.'; Editable = false; }
                field(periodStart; Rec."Period Start") { Caption = 'Period Start'; }
                field(periodEnd; Rec."Period End") { Caption = 'Period End'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(retentionPct; Rec."Retention %") { Caption = 'Retention %'; }
                field(thisPeriodAmount; Rec."This Period Amount") { Caption = 'This Period Amount'; Editable = false; }
                field(retentionThisPeriod; Rec."Retention This Period") { Caption = 'Retention This Period'; Editable = false; }
                field(netPayableThisPeriod; Rec."Net Payable This Period") { Caption = 'Net Payable This Period'; Editable = false; }
                field(noSeries; Rec."No. Series") { Caption = 'No. Series'; Editable = false; }
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
