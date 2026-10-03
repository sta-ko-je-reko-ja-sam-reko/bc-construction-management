namespace Construction.CostBreakdown;

using Construction.Setup;
using Microsoft.Projects.Project.Job;

tableextension 60100 "CONS Job Task" extends "Job Task"
{
    fields
    {
        field(60000; "CONS Cost Type"; Enum "CONS Cost Type")
        {
            Caption = 'Cost Type';
            DataClassification = CustomerContent;
        }
        field(60001; "CONS % Complete"; Decimal)
        {
            Caption = '% Complete';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
    }
}
