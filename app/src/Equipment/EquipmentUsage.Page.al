namespace Construction.Equipment;

using Construction.Core;

page 50423 "CONS Equipment Usage"
{
    PageType = Worksheet;
    ApplicationArea = CONSEquipment;
    UsageCategory = Tasks;
    SourceTable = "CONS Equipment Usage";
    AutoSplitKey = true;
    Caption = 'Equipment Usage';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Equipment No."; Rec."Equipment No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Job Task No."; Rec."Job Task No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field(Description; Rec.Description) { }
                field(Quantity; Rec.Quantity) { }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { }
                field("Unit Cost"; Rec."Unit Cost") { }
                field("Total Cost"; Rec."Total Cost") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                Caption = 'Post';
                ToolTip = 'Posts the equipment usage lines to the project ledger.';
                Image = Post;

                trigger OnAction()
                var
                    EquipmentUsagePost: Codeunit "CONS Equipment Usage-Post";
                begin
                    EquipmentUsagePost.PostBatch();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Post_Promoted; Post) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Equipment & Plant");
    end;
}
