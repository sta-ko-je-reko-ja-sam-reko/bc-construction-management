namespace Construction.Setup;

using Construction.Core;

page 50018 "CONS Feature Setup Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    Caption = 'Feature Setup';

    layout
    {
        area(Content)
        {
            group(Intro)
            {
                ShowCaption = false;
                Visible = Step = Step::Intro;

                field(IntroHeadline; HeadlineTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                }
                field(FeatureNameField; FeatureName)
                {
                    Caption = 'Feature';
                    Editable = false;
                    ToolTip = 'Specifies the feature you are setting up.';
                }
                field(FeatureDescField; FeatureDesc)
                {
                    Caption = 'About this feature';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies what the feature does and what this setup step prepares.';
                }
                field(RestartNoteField; RestartNoteTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                    Style = StrongAccent;
                }
            }
            group(Options)
            {
                Caption = 'What do you want to do?';
                Visible = Step = Step::Options;

                field(DoEnableField; DoEnable)
                {
                    Caption = 'Enable this feature';
                    ToolTip = 'Specifies that the feature is turned on so its pages and actions appear. Clearing this turns the feature off.';
                    Visible = HasToggle;
                }
                field(DoNoSeriesField; DoNoSeries)
                {
                    Caption = 'Create and assign number series';
                    ToolTip = 'Specifies that default number series for this feature''s documents are created and assigned, if they are not set yet.';
                    Visible = HasNoSeries;
                }
                field(DoDemoDataField; DoDemoData)
                {
                    Caption = 'Import demo data';
                    ToolTip = 'Specifies that sample construction data for this feature is created so you can try it immediately.';
                }
            }
            group(Done)
            {
                ShowCaption = false;
                Visible = Step = Step::Done;

                field(DoneText; DoneTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(BackAction)
            {
                Caption = 'Back';
                ToolTip = 'Goes back to the previous step.';
                Image = PreviousRecord;
                Enabled = Step <> Step::Intro;

                trigger OnAction()
                begin
                    if Step > Step::Intro then
                        Step := Step - 1;
                end;
            }
            action(NextAction)
            {
                Caption = 'Next';
                ToolTip = 'Goes to the next step.';
                Image = NextRecord;
                Enabled = Step <> Step::Done;

                trigger OnAction()
                begin
                    if Step < Step::Done then
                        Step := Step + 1;
                end;
            }
            action(FinishAction)
            {
                Caption = 'Finish';
                ToolTip = 'Applies your choices for this feature and returns to the setup list.';
                Image = Approve;
                Enabled = Step = Step::Done;

                trigger OnAction()
                var
                    GuidedSetup: Codeunit "CONS Guided Setup";
                begin
                    GuidedSetup.ApplyWizardChoices(Module, Feature, HasToggle, DoEnable, DoNoSeries, DoDemoData);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        Module: Enum "CONS Module";
        Feature: Enum "CONS Feature";
        Step: Option Intro,Options,Done;
        HasToggle: Boolean;
        HasNoSeries: Boolean;
        DoEnable: Boolean;
        DoNoSeries: Boolean;
        DoDemoData: Boolean;
        FeatureName: Text[100];
        FeatureDesc: Text[250];
        HeadlineTxt: Text;
        RestartNoteTxt: Text;
        DoneTxt: Text;
        HeadlineLbl: Label 'Let''s set up this construction feature.';
        RestartNoteLbl: Label 'Note: when you finish the whole setup and close the feature list, the session may restart so your changes take effect. After that the app is ready to use.';
        DoneLbl: Label 'Choose Finish to apply your selections. You will return to the feature list, where you can set up the next feature.';

    /// <summary>Passes the selected step's feature context into the wizard before it is shown. Call before RunModal.</summary>
    procedure SetContext(NewModule: Enum "CONS Module"; NewFeature: Enum "CONS Feature"; NewHasToggle: Boolean; NewName: Text[100]; NewDesc: Text[250]; CurrentlyEnabled: Boolean)
    begin
        Module := NewModule;
        Feature := NewFeature;
        HasToggle := NewHasToggle;
        FeatureName := NewName;
        FeatureDesc := NewDesc;
        DoEnable := CurrentlyEnabled or not NewHasToggle;
        HasNoSeries := ModuleHasNoSeries(NewModule);
        DoNoSeries := HasNoSeries;
        DoDemoData := false;
    end;

    /// <summary>Whether the module owns any document number series the wizard can create.</summary>
    local procedure ModuleHasNoSeries(TheModule: Enum "CONS Module"): Boolean
    begin
        exit(TheModule in [
            TheModule::Foundation,
            TheModule::Estimating,
            TheModule::"Progress Billing",
            TheModule::Subcontracts,
            TheModule::"Equipment & Plant"]);
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Intro;
        HeadlineTxt := HeadlineLbl;
        RestartNoteTxt := RestartNoteLbl;
        DoneTxt := DoneLbl;
    end;
}
