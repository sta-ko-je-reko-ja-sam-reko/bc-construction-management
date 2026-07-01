namespace Construction.Core;

using System.Environment.Configuration;

tableextension 50321 "CONS Application Area Setup" extends "Application Area Setup"
{
    fields
    {
        field(50320; "CONS Estimating"; Boolean)
        {
            Caption = 'Construction Estimating';
            DataClassification = SystemMetadata;
        }
        field(50321; "CONS Cost Control"; Boolean)
        {
            Caption = 'Construction Cost Control';
            DataClassification = SystemMetadata;
        }
        field(50322; "CONS Progress Billing"; Boolean)
        {
            Caption = 'Construction Progress Billing';
            DataClassification = SystemMetadata;
        }
        field(50323; "CONS Subcontracts"; Boolean)
        {
            Caption = 'Construction Subcontracts';
            DataClassification = SystemMetadata;
        }
        field(50324; "CONS Equipment"; Boolean)
        {
            Caption = 'Construction Equipment & Plant';
            DataClassification = SystemMetadata;
        }
        field(50325; "CONS Scheduling"; Boolean)
        {
            Caption = 'Construction Scheduling & Resource Planning';
            DataClassification = SystemMetadata;
        }
    }
}
