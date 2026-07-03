namespace Construction.Subcontracts;

using Construction.Setup;

/// <summary>
/// Subcontracts demo seeder — a subcontract with a subcontractor and 5% retention on the shared CONS-DEMO
/// project. Idempotent (skips when a subcontract already exists for the demo project). Message-free; reached
/// from the assisted-setup wizard and the demoSubcontracts [ServiceEnabled] API action. Ensures the Foundation
/// demo context (project + vendor) via "CONS Demo Foundation" first.
/// </summary>
codeunit 50035 "CONS Demo Subcontracts"
{
    Access = Public;

    /// <summary>Seed a demo subcontract on CONS-DEMO. Idempotent — uses a fixed subcontract No. (no number series), so it also runs cleanly from the API/MCP path where series may not be set up yet.</summary>
    procedure Import()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        DemoFoundation: Codeunit "CONS Demo Foundation";
        RecRef: RecordRef;
        ProjectNo: Code[20];
    begin
        ProjectNo := DemoFoundation.EnsureProjectContext();
        if ConfigPackageBuilder.EnsurePackage(SubcPkgCodeTok, SubcPkgNameLbl) then
            ConfigPackageBuilder.AddOwnTable(SubcPkgCodeTok, Database::"CONS Subcontract Header");
        if SubcontractHeader.Get(DemoSubcNoTok) then
            exit;
        SubcontractHeader.Init();
        SubcontractHeader."No." := DemoSubcNoTok;
        SubcontractHeader.Insert(true);
        SubcontractHeader.Validate("Project No.", ProjectNo);
        SubcontractHeader.Validate("Buy-from Vendor No.", DemoFoundation.DemoPartyCode());
        SubcontractHeader.Validate(Description, DemoSubcontractDescTxt);
        SubcontractHeader.Validate("Retention %", 5);
        SubcontractHeader.Modify(true);

        SubcontractHeader.SetRecFilter();
        RecRef.GetTable(SubcontractHeader);
        ConfigPackageBuilder.SnapshotTable(SubcPkgCodeTok, RecRef);
    end;

    var
        DemoSubcNoTok: Label 'CONS-DEMO-SUB', Locked = true, MaxLength = 20;
        SubcPkgCodeTok: Label 'CONS-SUBCONTRACTS', Locked = true, MaxLength = 20;
        SubcPkgNameLbl: Label 'Construction Demo - Subcontracts', MaxLength = 50;
        DemoSubcontractDescTxt: Label 'Demo groundworks subcontract';
}
