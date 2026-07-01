namespace Construction.Estimating;

using Construction.Setup;
using Microsoft.Foundation.NoSeries;

codeunit 50064 "CONS BoQ Header Logic" implements "CONS IBoQHeader"
{
    Access = Public;

    procedure Trigger_OnInsert(var BoQHeader: Record "CONS BoQ Header")
    var
        ConstructionSetup: Record "CONS Construction Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if BoQHeader."No." <> '' then
            exit;
        ConstructionSetup.Get();
        ConstructionSetup.TestField("BoQ Nos.");
        BoQHeader."No. Series" := ConstructionSetup."BoQ Nos.";
        BoQHeader."No." := NoSeries.GetNextNo(BoQHeader."No. Series");
    end;

    procedure Trigger_OnDelete(var BoQHeader: Record "CONS BoQ Header")
    var
        BoQLine: Record "CONS BoQ Line";
    begin
        BoQLine.SetRange("Document No.", BoQHeader."No.");
        BoQLine.DeleteAll(true);
    end;
}
