namespace Construction.Equipment;

using Construction.Setup;

/// <summary>
/// Equipment &amp; Plant demo seeder — two pieces of demo equipment with cost and hire rates. Idempotent (skips
/// when the first demo item already exists). Message-free; reached from the assisted-setup wizard and the
/// demoEquipment [ServiceEnabled] API action. Self-contained — equipment has no project dependency, so it does
/// not touch the Foundation demo context.
/// </summary>
codeunit 50036 "CONS Demo Equipment"
{
    Access = Public;

    /// <summary>Seed two demo equipment cards. Idempotent — uses fixed equipment No.s (no number series), so it also runs cleanly from the API/MCP path where series may not be set up yet.</summary>
    procedure Import()
    var
        Equipment: Record "CONS Equipment";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        RecRef: RecordRef;
    begin
        if ConfigPackageBuilder.EnsurePackage(EquipPkgCodeTok, EquipPkgNameLbl) then
            ConfigPackageBuilder.AddOwnTable(EquipPkgCodeTok, Database::"CONS Equipment");
        if Equipment.Get(DemoEquip1NoTok) then
            exit;
        InsertEquipment(DemoEquip1NoTok, DemoEquip1Txt, 45, 70);
        InsertEquipment(DemoEquip2NoTok, DemoEquip2Txt, 30, 55);

        Equipment.SetFilter("No.", '%1|%2', DemoEquip1NoTok, DemoEquip2NoTok);
        RecRef.GetTable(Equipment);
        ConfigPackageBuilder.SnapshotTable(EquipPkgCodeTok, RecRef);
    end;

    local procedure InsertEquipment(EquipNo: Code[20]; EquipDescription: Text[100]; CostRate: Decimal; HireRate: Decimal)
    var
        Equipment: Record "CONS Equipment";
    begin
        Equipment.Init();
        Equipment."No." := EquipNo;
        Equipment.Validate(Description, EquipDescription);
        Equipment."Cost Rate" := CostRate;
        Equipment."Hire Rate" := HireRate;
        Equipment.Insert(true);
    end;

    var
        DemoEquip1NoTok: Label 'CONS-DEMO-EQ1', Locked = true, MaxLength = 20;
        DemoEquip2NoTok: Label 'CONS-DEMO-EQ2', Locked = true, MaxLength = 20;
        EquipPkgCodeTok: Label 'CONS-EQUIPMENT', Locked = true, MaxLength = 20;
        EquipPkgNameLbl: Label 'Construction Demo - Equipment', MaxLength = 50;
        DemoEquip1Txt: Label 'Demo Excavator 20t';
        DemoEquip2Txt: Label 'Demo Tower Crane';
}
