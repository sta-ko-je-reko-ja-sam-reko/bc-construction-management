namespace Construction.Equipment;

using Construction.Core;

page 50429 "CONS Equipment Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CONS Equipment Setup";
    Caption = 'Equipment Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Rec.Enabled) { }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Equipment Nos."; Rec."Equipment Nos.") { }
                field("Default Rate Unit of Measure"; Rec."Default Rate Unit of Measure") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        OpeningEnabled := Rec.Enabled;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ApplyEnabledChangeIfNeeded();
        exit(true);
    end;

    local procedure ApplyEnabledChangeIfNeeded()
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        if not Rec.Get() then
            exit;
        if Rec.Enabled = OpeningEnabled then
            exit;
        FeatureMgt.ApplyExperienceChange();
    end;

    var
        OpeningEnabled: Boolean;
}
