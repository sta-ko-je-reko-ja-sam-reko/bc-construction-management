namespace Construction.Equipment;

using Construction.Core;

page 50421 "CONS Equipment List"
{
    PageType = List;
    ApplicationArea = CONSEquipment;
    UsageCategory = Lists;
    SourceTable = "CONS Equipment";
    CardPageId = "CONS Equipment Card";
    Caption = 'Equipment';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Equipment)
            {
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field("Equipment Type"; Rec."Equipment Type") { }
                field(Status; Rec.Status) { }
                field(Ownership; Rec.Ownership) { }
                field("Location Code"; Rec."Location Code") { }
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
