namespace Construction.Scheduling;

using Construction.Core;

page 50462 "CONS Scheduling Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CONS Scheduling Setup";
    Caption = 'Scheduling Setup';
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
            group(Defaults)
            {
                Caption = 'Defaults';
                field("Default Dependency Type"; Rec."Default Dependency Type") { }
                field("Include Nonworking Days"; Rec."Include Nonworking Days") { }
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
