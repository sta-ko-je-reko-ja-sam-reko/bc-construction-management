namespace Construction.CostBreakdown;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

tableextension 50100 "CONS Job Task" extends "Job Task"
{
    fields
    {
        field(50000; "CONS Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
        }
        field(50001; "CONS % Complete"; Decimal)
        {
            Caption = '% Complete';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
    }
}
