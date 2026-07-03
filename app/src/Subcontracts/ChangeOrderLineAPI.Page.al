namespace Construction.Subcontracts;

using Construction.Core;

page 50293 "CONS Change Order Line API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'changeOrderLine';
    EntitySetName = 'changeOrderLines';
    EntityCaption = 'Change Order Line';
    EntitySetCaption = 'Change Order Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Change Order Line";
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
                field(description; Rec.Description) { Caption = 'Description'; }
                field(costType; Rec."Cost Type") { Caption = 'Cost Type'; }
                field(amount; Rec.Amount) { Caption = 'Amount'; }
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
