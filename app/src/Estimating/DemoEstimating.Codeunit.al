namespace Construction.Estimating;

using Construction.Setup;

/// <summary>
/// Estimating demo seeder — a Bill of Quantities with lines on the shared CONS-DEMO project. Idempotent (skips
/// when a BoQ already exists for the demo project). Message-free; called from the assisted-setup wizard and the
/// demoEstimating [ServiceEnabled] API action alike. Depends on the Foundation demo context (project + customer),
/// which it ensures via "CONS Demo Foundation" before seeding its own records.
/// </summary>
codeunit 50032 "CONS Demo Estimating"
{
    Access = Public;

    /// <summary>Seed a demo Bill of Quantities on CONS-DEMO. Idempotent — uses a fixed BoQ No. (no number series), so it also runs cleanly from the API/MCP path where series may not be set up yet.</summary>
    procedure Import()
    var
        BoQHeader: Record "CONS BoQ Header";
        BoQLine: Record "CONS BoQ Line";
        ConfigPackageBuilder: Codeunit "CONS Config Package Builder";
        DemoFoundation: Codeunit "CONS Demo Foundation";
        RecRef: RecordRef;
        ProjectNo: Code[20];
    begin
        ProjectNo := DemoFoundation.EnsureProjectContext();
        if ConfigPackageBuilder.EnsurePackage(EstimatingPkgCodeTok, EstimatingPkgNameLbl) then begin
            ConfigPackageBuilder.AddOwnTable(EstimatingPkgCodeTok, Database::"CONS BoQ Header");
            ConfigPackageBuilder.AddOwnTable(EstimatingPkgCodeTok, Database::"CONS BoQ Line");
        end;
        if BoQHeader.Get(DemoBoQNoTok) then
            exit;
        BoQHeader.Init();
        BoQHeader."No." := DemoBoQNoTok;
        BoQHeader.Insert(true);
        BoQHeader.Validate(Description, DemoBoQDescTxt);
        BoQHeader.Validate("Project No.", ProjectNo);
        BoQHeader.Validate("Bill-to Customer No.", DemoFoundation.DemoPartyCode());
        BoQHeader.Modify(true);

        InsertBoQLine(BoQHeader."No.", 10000, DemoBoQLine1Txt, 250, 35);
        InsertBoQLine(BoQHeader."No.", 20000, DemoBoQLine2Txt, 120, 90);

        BoQHeader.SetRecFilter();
        RecRef.GetTable(BoQHeader);
        ConfigPackageBuilder.SnapshotTable(EstimatingPkgCodeTok, RecRef);
        BoQLine.SetRange("Document No.", BoQHeader."No.");
        RecRef.GetTable(BoQLine);
        ConfigPackageBuilder.SnapshotTable(EstimatingPkgCodeTok, RecRef);
    end;

    local procedure InsertBoQLine(DocumentNo: Code[20]; LineNo: Integer; LineDescription: Text[100]; Qty: Decimal; UnitCostValue: Decimal)
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.Init();
        BoQLine."Document No." := DocumentNo;
        BoQLine."Line No." := LineNo;
        BoQLine.Validate(Description, LineDescription);
        BoQLine.Validate(Quantity, Qty);
        BoQLine.Validate("Unit Cost", UnitCostValue);
        BoQLine.Insert(true);
    end;

    var
        DemoBoQNoTok: Label 'CONS-DEMO-BOQ', Locked = true, MaxLength = 20;
        EstimatingPkgCodeTok: Label 'CONS-ESTIMATING', Locked = true, MaxLength = 20;
        EstimatingPkgNameLbl: Label 'Construction Demo - Estimating', MaxLength = 50;
        DemoBoQDescTxt: Label 'Demo Bill of Quantities';
        DemoBoQLine1Txt: Label 'Concrete to foundations (m3)';
        DemoBoQLine2Txt: Label 'Structural steel erection (t)';
}
