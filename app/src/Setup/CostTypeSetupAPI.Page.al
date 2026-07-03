namespace Construction.Setup;

page 50294 "CONS Cost Type Setup API"
{
    PageType = API;
    APIPublisher = 'dmom';
    APIGroup = 'construction';
    APIVersion = 'v1.0';
    EntityName = 'costTypeSetup';
    EntitySetName = 'costTypeSetups';
    EntityCaption = 'Cost Type Setup';
    EntitySetCaption = 'Cost Type Setups';
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    SourceTable = "CONS Cost Type Setup";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(costType; Rec."Cost Type") { Caption = 'Cost Type'; }
                field(defaultGLAccountNo; Rec."Default G/L Account No.") { Caption = 'Default G/L Account No.'; }
                field(defaultWorkTypeCode; Rec."Default Work Type Code") { Caption = 'Default Work Type Code'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date'; Editable = false; }
            }
        }
    }
}
