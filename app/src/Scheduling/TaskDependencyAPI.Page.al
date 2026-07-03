namespace Construction.Scheduling;

using Construction.Core;

page 50476 "CONS Task Dependency API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'taskDependency';
    EntitySetName = 'taskDependencies';
    EntityCaption = 'Task Dependency';
    EntitySetCaption = 'Task Dependencies';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Task Dependency";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(jobNo; Rec."Job No.") { Caption = 'Project No.'; }
                field(jobTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(predecessorTaskNo; Rec."Predecessor Task No.") { Caption = 'Predecessor Task No.'; }
                field(dependencyType; Rec."Dependency Type") { Caption = 'Dependency Type'; }
                field(lagDays; Rec."Lag (Days)") { Caption = 'Lag (Days)'; }
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
