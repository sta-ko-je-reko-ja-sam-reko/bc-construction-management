namespace Construction.Estimating;

interface "CONS IBoQLine"
{
    /// <summary>Default logic for a Bill of Quantities line. Implemented by "CONS BoQ Line Logic";
    /// injected into the table via CONS BoQ Line.Define() for tests or downstream overrides.</summary>

    procedure Trigger_OnInsert(var BoQLine: Record "CONS BoQ Line");
    procedure Validate_LineType(var BoQLine: Record "CONS BoQ Line");
    procedure Validate_Type(var BoQLine: Record "CONS BoQ Line"; xBoQLine: Record "CONS BoQ Line");
    procedure Validate_No(var BoQLine: Record "CONS BoQ Line");
    procedure Validate_Amounts(var BoQLine: Record "CONS BoQ Line");
}
