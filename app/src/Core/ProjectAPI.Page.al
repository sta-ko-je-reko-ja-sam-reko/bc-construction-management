namespace Construction.Core;

using Microsoft.Projects.Project.Job;

page 50295 "CONS Project API"
{
    PageType = API;
    APIPublisher = 'yourcompany';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'project';
    EntitySetName = 'projects';
    EntityCaption = 'Project';
    EntitySetCaption = 'Projects';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = Job;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(displayName; Rec.Description) { Caption = 'Display Name'; }
                field(constructionProject; Rec."CONS Construction Project") { Caption = 'Construction Project'; }
                field(defaultCostType; Rec."CONS Default Cost Type") { Caption = 'Default Cost Type'; }
                field(contractValue; Rec."CONS Contract Value") { Caption = 'Contract Value'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
