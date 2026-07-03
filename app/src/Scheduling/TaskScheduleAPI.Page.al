namespace Construction.Scheduling;

using Construction.Core;
using Microsoft.Projects.Project.Job;

page 50475 "CONS Task Schedule API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'taskSchedule';
    EntitySetName = 'taskSchedules';
    EntityCaption = 'Task Schedule';
    EntitySetCaption = 'Task Schedules';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "Job Task";
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(projectNo; Rec."Job No.") { Caption = 'Project No.'; Editable = false; }
                field(projectTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(plannedStartDate; Rec."CONS Planned Start Date") { Caption = 'Planned Start Date'; }
                field(plannedEndDate; Rec."CONS Planned End Date") { Caption = 'Planned End Date'; }
                field(durationDays; Rec."CONS Duration (Days)") { Caption = 'Duration (Days)'; }
                field(scheduled; Rec."CONS Scheduled") { Caption = 'Scheduled'; }
                field(percentComplete; Rec."CONS % Complete") { Caption = '% Complete'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Scheduling);
        exit(true);
    end;

    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
}
