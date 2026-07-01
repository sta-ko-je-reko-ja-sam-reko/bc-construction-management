namespace Construction.Core;

using Construction.Retention;
using Microsoft.Projects.Project.Job;

pageextension 50006 "CONS Project Card" extends "Job Card"
{
    layout
    {
        addlast(General)
        {
            field("CONS Construction Project"; Rec."CONS Construction Project")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this project is managed with Construction Management features.';
            }
            field("CONS Default Cost Type"; Rec."CONS Default Cost Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default construction cost type for this project''s estimate and budget lines.';
                Enabled = Rec."CONS Construction Project";
            }
            field("CONS Contract Value"; Rec."CONS Contract Value")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the agreed contract value for the project.';
                Enabled = Rec."CONS Construction Project";
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("CONS Release Retention")
            {
                ApplicationArea = All;
                Caption = 'Release Retention';
                ToolTip = 'Creates a draft sales invoice that releases the full outstanding retention held for this project.';
                Image = ReleaseDoc;

                trigger OnAction()
                var
                    RetentionRelease: Codeunit "CONS Retention Release";
                begin
                    RetentionRelease.ReleaseFullOutstanding(Rec."No.");
                end;
            }
            action("CONS Retention Entries")
            {
                ApplicationArea = All;
                Caption = 'Retention Entries';
                ToolTip = 'Shows the retention withheld and released for this project.';
                Image = Entries;
                RunObject = page "CONS Retention Entries";
                RunPageLink = "Project No." = field("No.");
            }
        }
    }
}
