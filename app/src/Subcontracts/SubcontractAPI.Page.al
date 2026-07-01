namespace Construction.Subcontracts;

using Construction.Core;

page 50288 "CONS Subcontract API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'subcontract';
    EntitySetName = 'subcontracts';
    EntityCaption = 'Subcontract';
    EntitySetCaption = 'Subcontracts';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Subcontract Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(buyFromVendorNo; Rec."Buy-from Vendor No.") { Caption = 'Subcontractor No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(retentionPct; Rec."Retention %") { Caption = 'Retention %'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(endingDate; Rec."Ending Date") { Caption = 'Ending Date'; }
                field(subcontractValue; Rec."Subcontract Value") { Caption = 'Subcontract Value'; Editable = false; }
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
