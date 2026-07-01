namespace Construction.Estimating;

interface "CONS IBoQHeader"
{
    /// <summary>Default logic for a Bill of Quantities header. Implemented by "CONS BoQ Header Logic";
    /// injected into the table via CONS BoQ Header.Define() for tests or downstream overrides.</summary>

    procedure Trigger_OnInsert(var BoQHeader: Record "CONS BoQ Header");
    procedure Trigger_OnDelete(var BoQHeader: Record "CONS BoQ Header");
}
