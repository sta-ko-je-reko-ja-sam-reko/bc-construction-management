namespace Construction.Retention;

page 50287 "CONS Retention Entry API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'retentionEntry';
    EntitySetName = 'retentionEntries';
    EntityCaption = 'Retention Entry';
    EntitySetCaption = 'Retention Entries';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Retention Entry";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(projectNo; Rec."Project No.") { Caption = 'Project No.'; }
                field(direction; Rec.Direction) { Caption = 'Direction'; }
                field(entryType; Rec."Entry Type") { Caption = 'Entry Type'; }
                field(documentNo; Rec."Document No.") { Caption = 'Document No.'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(accountNo; Rec."Account No.") { Caption = 'Account No.'; }
                field(amount; Rec.Amount) { Caption = 'Amount'; }
                field(gLAccountNo; Rec."G/L Account No.") { Caption = 'G/L Account No.'; }
                field(applicationNo; Rec."Application No.") { Caption = 'Application No.'; }
                field(dueDate; Rec."Due Date") { Caption = 'Due Date'; }
                field(open; Rec.Open) { Caption = 'Open'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
