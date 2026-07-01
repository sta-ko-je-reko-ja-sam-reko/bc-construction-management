namespace Construction.Core;

using Construction.Setup;

codeunit 50009 "CONS Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeSetup();
        SeedCostTypeSetup();
        RegisterAssistedSetup();
    end;

    local procedure RegisterAssistedSetup()
    var
        GuidedSetup: Codeunit "CONS Guided Setup";
    begin
        GuidedSetup.RegisterAssistedSetup();
    end;

    local procedure InitializeSetup()
    var
        ConstructionSetup: Record "CONS Construction Setup";
    begin
        ConstructionSetup.InitSetup();
    end;

    local procedure SeedCostTypeSetup()
    var
        CostTypeSetup: Record "CONS Cost Type Setup";
        CostType: Enum "CONS Cost Type";
        Ordinals: List of [Integer];
        Ordinal: Integer;
    begin
        Ordinals := Enum::"CONS Cost Type".Ordinals();
        foreach Ordinal in Ordinals do begin
            CostType := Enum::"CONS Cost Type".FromInteger(Ordinal);
            if not CostTypeSetup.Get(CostType) then begin
                CostTypeSetup.Init();
                CostTypeSetup."Cost Type" := CostType;
                CostTypeSetup.Insert();
            end;
        end;
    end;
}
