namespace Construction.Subcontracts;

using Construction.Core;

page 50292 "CONS Change Order API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'changeOrder';
    EntitySetName = 'changeOrders';
    EntityCaption = 'Change Order';
    EntitySetCaption = 'Change Orders';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Change Order Header";
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
                field(changeType; Rec."Change Type") { Caption = 'Change Type'; }
                field(subcontractNo; Rec."Subcontract No.") { Caption = 'Subcontract No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(reason; Rec.Reason) { Caption = 'Reason'; }
                field(documentDate; Rec."Document Date") { Caption = 'Document Date'; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(totalAmount; Rec."Total Amount") { Caption = 'Total Amount'; Editable = false; }
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
