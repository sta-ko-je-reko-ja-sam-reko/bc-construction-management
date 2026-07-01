namespace Construction.Subcontracts;

using Construction.Core;

page 50289 "CONS Subcontract Line API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'subcontractLine';
    EntitySetName = 'subcontractLines';
    EntityCaption = 'Subcontract Line';
    EntitySetCaption = 'Subcontract Lines';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Subcontract Line";
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
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(lineAmount; Rec."Line Amount") { Caption = 'Line Amount'; Editable = false; }
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
