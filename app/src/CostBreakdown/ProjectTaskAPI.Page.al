namespace Construction.CostBreakdown;

using Microsoft.Projects.Project.Job;

page 50296 "CONS Project Task API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'projectTask';
    EntitySetName = 'projectTasks';
    EntityCaption = 'Project Task';
    EntitySetCaption = 'Project Tasks';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "Job Task";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(projectNo; Rec."Job No.") { Caption = 'Project No.'; }
                field(projectTaskNo; Rec."Job Task No.") { Caption = 'Project Task No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(costType; Rec."CONS Cost Type") { Caption = 'Cost Type'; }
                field(percentComplete; Rec."CONS % Complete") { Caption = '% Complete'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
