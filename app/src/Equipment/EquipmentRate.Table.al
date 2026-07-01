namespace Construction.Equipment;

using Microsoft.Foundation.UOM;
using Microsoft.Projects.Project.Job;

table 50411 "CONS Equipment Rate"
{
    Caption = 'Equipment Rate';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Equipment";
            ToolTip = 'Specifies the equipment the rate applies to.';
        }
        field(2; "Project No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project the rate applies to. Leave blank to apply the rate to all projects.';
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date from which this rate applies.';
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ToolTip = 'Specifies the unit of measure the rate applies to.';
        }
        field(11; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the unit cost of using the equipment for this project and starting date.';
        }
        field(12; "Hire Rate"; Decimal)
        {
            Caption = 'Hire Rate';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            ToolTip = 'Specifies the charge or hire rate of the equipment for this project and starting date.';
        }
    }

    keys
    {
        key(PK; "Equipment No.", "Project No.", "Starting Date")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Returns the most-applicable unit cost for the equipment on the given date: a rate matching the
    /// exact project (latest starting date on or before the date) is preferred, otherwise a blank-project
    /// rate (latest starting date on or before the date). Returns 0 when no rate applies so the caller
    /// can fall back to the equipment's default cost rate.
    /// </summary>
    /// <param name="EquipmentNo">The equipment to find the rate for.</param>
    /// <param name="ProjectNo">The project to match; the blank-project rate is used when no project rate exists.</param>
    /// <param name="OnDate">The date the rate must apply on.</param>
    /// <returns>The applicable unit cost, or 0 when none is found.</returns>
    internal procedure FindUnitCost(EquipmentNo: Code[20]; ProjectNo: Code[20]; OnDate: Date): Decimal
    var
        EquipmentRate: Record "CONS Equipment Rate";
    begin
        EquipmentRate.SetLoadFields("Unit Cost");
        EquipmentRate.SetRange("Equipment No.", EquipmentNo);
        if OnDate <> 0D then
            EquipmentRate.SetRange("Starting Date", 0D, OnDate);

        if ProjectNo <> '' then begin
            EquipmentRate.SetRange("Project No.", ProjectNo);
            if EquipmentRate.FindLast() then
                exit(EquipmentRate."Unit Cost");
        end;

        EquipmentRate.SetRange("Project No.", '');
        if EquipmentRate.FindLast() then
            exit(EquipmentRate."Unit Cost");

        exit(0);
    end;

    /// <summary>
    /// Returns the most-applicable hire rate for the equipment on the given date, matching the exact
    /// project first and then the blank-project rate. Returns 0 when no rate applies.
    /// </summary>
    /// <param name="EquipmentNo">The equipment to find the rate for.</param>
    /// <param name="ProjectNo">The project to match; the blank-project rate is used when no project rate exists.</param>
    /// <param name="OnDate">The date the rate must apply on.</param>
    /// <returns>The applicable hire rate, or 0 when none is found.</returns>
    internal procedure FindHireRate(EquipmentNo: Code[20]; ProjectNo: Code[20]; OnDate: Date): Decimal
    var
        EquipmentRate: Record "CONS Equipment Rate";
    begin
        EquipmentRate.SetLoadFields("Hire Rate");
        EquipmentRate.SetRange("Equipment No.", EquipmentNo);
        if OnDate <> 0D then
            EquipmentRate.SetRange("Starting Date", 0D, OnDate);

        if ProjectNo <> '' then begin
            EquipmentRate.SetRange("Project No.", ProjectNo);
            if EquipmentRate.FindLast() then
                exit(EquipmentRate."Hire Rate");
        end;

        EquipmentRate.SetRange("Project No.", '');
        if EquipmentRate.FindLast() then
            exit(EquipmentRate."Hire Rate");

        exit(0);
    end;
}
