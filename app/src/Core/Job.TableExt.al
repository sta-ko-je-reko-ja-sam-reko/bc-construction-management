namespace Construction.Core;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

tableextension 60005 "CONS Job" extends Job
{
    fields
    {
        field(60000; "CONS Construction Project"; Boolean)
        {
            Caption = 'Construction Project';
            DataClassification = CustomerContent;
        }
        field(60001; "CONS Default Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Default Cost Type';
            DataClassification = CustomerContent;
        }
        field(60002; "CONS Contract Value"; Decimal)
        {
            Caption = 'Contract Value';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
    }
}
