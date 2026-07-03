namespace Construction.Core;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

pageextension 50007 "CONS Project List" extends "Job List"
{
    layout
    {
        addafter(Description)
        {
            field("CONS Construction Project"; Rec."CONS Construction Project")
            {
                ApplicationArea = All;
                AccessByPermission = tabledata "CONS Construction Setup" = R;
                ToolTip = 'Specifies whether this project is managed with Construction Management features.';
            }
        }
    }
}
