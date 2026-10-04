namespace Construction.Test;

using Construction.Estimating;

/// <summary>Fake BoQ line logic injected through the table's Define(): marks the line instead of calculating, proving the table triggers delegate to the injected implementation.</summary>
codeunit 64019 "CONS Test BoQ Line Logic" implements "CONS IBoQLine"
{
    procedure Trigger_OnInsert(var BoQLine: Record "CONS BoQ Line")
    begin
        BoQLine.Description := FakeInsertTok;
    end;

    procedure Validate_LineType(var BoQLine: Record "CONS BoQ Line")
    begin
    end;

    procedure Validate_Type(var BoQLine: Record "CONS BoQ Line"; xBoQLine: Record "CONS BoQ Line")
    begin
    end;

    procedure Validate_No(var BoQLine: Record "CONS BoQ Line")
    begin
    end;

    procedure Validate_Amounts(var BoQLine: Record "CONS BoQ Line")
    begin
        BoQLine."Total Cost" := -1;
    end;

    var
        FakeInsertTok: Label 'FAKE INSERT', Locked = true;
}
