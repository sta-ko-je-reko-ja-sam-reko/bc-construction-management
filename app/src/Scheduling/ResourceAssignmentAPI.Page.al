namespace Construction.Scheduling;

using Construction.Core;

page 50477 "CONS Resource Assignment API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'resourceAssignment';
    EntitySetName = 'resourceAssignments';
    EntityCaption = 'Resource Assignment';
    EntitySetCaption = 'Resource Assignments';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Resource Assignment";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; Editable = false; }
                field(resourceNo; Rec."Resource No.") { Caption = 'Resource No.'; }
                field(jobNo; Rec."Job No.") { Caption = 'Project No.'; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(fromDate; Rec."From Date") { Caption = 'From Date'; }
                field(toDate; Rec."To Date") { Caption = 'To Date'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
