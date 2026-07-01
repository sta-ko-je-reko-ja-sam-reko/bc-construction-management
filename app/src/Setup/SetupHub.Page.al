namespace Construction.Setup;

using Construction.Core;

page 50017 "CONS Setup Hub"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CONS Setup Step";
    Editable = false;
    Caption = 'Construction Setup';
    InstructionalText = 'Set up each feature in order. For each one you can enable it, create its number series and load demo data. When you close this page the session may restart so the changes take effect, after which the app is ready to use.';
    AdditionalSearchTerms = 'construction,onboarding,assisted setup,getting started';

    layout
    {
        area(Content)
        {
            repeater(Steps)
            {
                ShowCaption = false;

                field("Step No."; Rec."Step No.")
                {
                }
                field(Name; Rec.Name)
                {
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        RunSelectedStep();
                    end;
                }
                field(Description; Rec.Description)
                {
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = StatusStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetUp)
            {
                Caption = 'Set Up';
                ToolTip = 'Opens the guided wizard for the selected feature so you can enable it, create its number series and load demo data.';
                Image = Setup;

                trigger OnAction()
                begin
                    RunSelectedStep();
                end;
            }
            action(DetailedSetup)
            {
                Caption = 'Detailed Setup';
                ToolTip = 'Opens the full setup page for the selected feature, for settings the wizard does not cover.';
                Image = SetupLines;

                trigger OnAction()
                begin
                    if Rec."Setup Page ID" <> 0 then
                        Page.Run(Rec."Setup Page ID");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SetUp_Promoted; SetUp)
                {
                }
                actionref(DetailedSetup_Promoted; DetailedSetup)
                {
                }
            }
        }
    }

    var
        GuidedSetup: Codeunit "CONS Guided Setup";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        OpeningFingerprint: Text;
        StatusStyle: Text;

    trigger OnOpenPage()
    begin
        GuidedSetup.PopulateSteps(Rec);
        OpeningFingerprint := FeatureMgt.GetEnabledFingerprint();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Completed then
            StatusStyle := 'Favorable'
        else
            StatusStyle := 'Subordinate';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        GuidedSetup.MarkAssistedSetupComplete();
        if FeatureMgt.GetEnabledFingerprint() <> OpeningFingerprint then
            FeatureMgt.RestartSession();
        exit(true);
    end;

    local procedure RunSelectedStep()
    begin
        GuidedSetup.RunWizardForStep(Rec);
        GuidedSetup.PopulateSteps(Rec);
        CurrPage.Update(false);
    end;
}
