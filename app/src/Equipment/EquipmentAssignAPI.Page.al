namespace Construction.Equipment;

using Construction.Core;

page 50445 "CONS Equipment Assign. API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'equipmentAssignment';
    EntitySetName = 'equipmentAssignments';
    EntityCaption = 'Equipment Assignment';
    EntitySetCaption = 'Equipment Assignments';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Equipment Assignment";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(equipmentNo; Rec."Equipment No.") { Caption = 'Equipment No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(fromDate; Rec."From Date") { Caption = 'From Date'; }
                field(toDate; Rec."To Date") { Caption = 'To Date'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
