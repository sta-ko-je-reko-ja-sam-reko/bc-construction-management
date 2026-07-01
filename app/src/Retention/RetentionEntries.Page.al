namespace Construction.Retention;

page 50208 "CONS Retention Entries"
{
    PageType = List;
    ApplicationArea = CONSProgressBilling;
    UsageCategory = History;
    SourceTable = "CONS Retention Entry";
    Caption = 'Retention Entries';
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Project No."; Rec."Project No.") { }
                field(Direction; Rec.Direction) { }
                field("Entry Type"; Rec."Entry Type") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Document No."; Rec."Document No.") { }
                field("Account No."; Rec."Account No.") { }
                field(Amount; Rec.Amount) { }
                field("Due Date"; Rec."Due Date") { }
                field(Open; Rec.Open) { }
                field("Application No."; Rec."Application No.") { }
                field("G/L Account No."; Rec."G/L Account No.") { }
            }
        }
    }
}
