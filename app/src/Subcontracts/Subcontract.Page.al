namespace Construction.Subcontracts;

using Construction.Core;
using Construction.Retention;

page 50260 "CONS Subcontract"
{
    PageType = Document;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Subcontract Header";
    Caption = 'Subcontract';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { }
                field("Project No."; Rec."Project No.") { }
                field(Description; Rec.Description) { }
                field("Retention %"; Rec."Retention %") { }
                field("Starting Date"; Rec."Starting Date") { }
                field("Ending Date"; Rec."Ending Date") { }
                field(Status; Rec.Status) { }
            }
            part(Lines; "CONS Subcontract Subform")
            {
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Totals)
            {
                field("Subcontract Value"; Rec."Subcontract Value") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("CONS Release Retention")
            {
                Caption = 'Release Retention';
                Image = ReleaseDoc;
                ToolTip = 'Creates a draft purchase invoice that releases the full outstanding retention held for this subcontractor on this project.';

                trigger OnAction()
                var
                    SubcRetentionRelease: Codeunit "CONS Subc Retention Release";
                begin
                    SubcRetentionRelease.ReleaseFullOutstanding(Rec."No.");
                end;
            }
            action("CONS Retention Entries")
            {
                Caption = 'Retention Entries';
                Image = Entries;
                ToolTip = 'Shows the retention withheld and released for this project.';
                RunObject = page "CONS Retention Entries";
                RunPageLink = "Project No." = field("Project No.");
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
    end;
}
