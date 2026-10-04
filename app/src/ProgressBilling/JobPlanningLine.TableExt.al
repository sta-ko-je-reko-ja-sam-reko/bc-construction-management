namespace Construction.ProgressBilling;

using Microsoft.Projects.Project.Planning;

tableextension 60167 "CONS Job Planning Line" extends "Job Planning Line"
{
    fields
    {
        field(60150; "CONS Progress Billing No."; Code[20])
        {
            Caption = 'Progress Billing No.';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the progress billing application this billable line was created for. Such lines carry the application amounts to the sales invoice through the standard project invoicing, and are never seeded as schedule-of-values lines.';
        }
    }
}
