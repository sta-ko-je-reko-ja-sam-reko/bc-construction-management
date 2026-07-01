namespace Construction.Equipment;

using Construction.Core;

page 50420 "CONS Equipment Card"
{
    PageType = Card;
    ApplicationArea = CONSEquipment;
    UsageCategory = None;
    SourceTable = "CONS Equipment";
    Caption = 'Equipment Card';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field("Description 2"; Rec."Description 2") { }
                field("Equipment Type"; Rec."Equipment Type") { }
                field(Status; Rec.Status) { }
                field(Ownership; Rec.Ownership) { }
                field("Resource No."; Rec."Resource No.") { }
                field("Location Code"; Rec."Location Code") { }
                field("Serial No."; Rec."Serial No.") { }
                field(Manufacturer; Rec.Manufacturer) { }
                field(Model; Rec.Model) { }
                field(Blocked; Rec.Blocked) { }
            }
            group(Costing)
            {
                Caption = 'Costing';
                field("Cost Rate"; Rec."Cost Rate") { }
                field("Hire Rate"; Rec."Hire Rate") { }
                field("Rate Unit of Measure"; Rec."Rate Unit of Measure") { }
            }
            group(Hire)
            {
                Caption = 'Hire';
                field("Vendor No."; Rec."Vendor No.") { }
                field("On-Hire Date"; Rec."On-Hire Date") { }
                field("Off-Hire Date"; Rec."Off-Hire Date") { }
            }
            group(Maintenance)
            {
                Caption = 'Maintenance';
                field("Meter Reading"; Rec."Meter Reading") { }
                field("Meter Unit"; Rec."Meter Unit") { }
                field("Last Service Date"; Rec."Last Service Date") { }
                field("Next Service Date"; Rec."Next Service Date") { }
                field("Next Service Meter"; Rec."Next Service Meter") { }
                field("In Maintenance"; Rec."In Maintenance") { }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Rates)
            {
                Caption = 'Rates';
                ToolTip = 'Opens the cost and hire rates defined for this equipment.';
                Image = Price;
                RunObject = page "CONS Equipment Rates";
                RunPageLink = "Equipment No." = field("No.");
            }
            action(Usage)
            {
                Caption = 'Usage';
                ToolTip = 'Opens the usage journal lines for this equipment.';
                Image = Job;
                RunObject = page "CONS Equipment Usage";
                RunPageLink = "Equipment No." = field("No.");
            }
            action(MaintenanceLog)
            {
                Caption = 'Maintenance';
                ToolTip = 'Opens the maintenance log for this equipment.';
                Image = Tools;
                RunObject = page "CONS Equipment Maintenance";
                RunPageLink = "Equipment No." = field("No.");
            }
            action(MeterEntries)
            {
                Caption = 'Meter Entries';
                ToolTip = 'Opens the meter readings recorded for this equipment.';
                Image = History;
                RunObject = page "CONS Equipment Meter Entries";
                RunPageLink = "Equipment No." = field("No.");
            }
            action(Assignments)
            {
                Caption = 'Assignments';
                ToolTip = 'Opens the project and task assignments for this equipment.';
                Image = Allocate;
                RunObject = page "CONS Equipment Assignments";
                RunPageLink = "Equipment No." = field("No.");
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
