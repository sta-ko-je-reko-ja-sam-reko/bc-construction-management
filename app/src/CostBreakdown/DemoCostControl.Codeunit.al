namespace Construction.CostBreakdown;

using Construction.Setup;

/// <summary>
/// Cost Control demo seeder — a context-only importer. Cost Control has no master/document records of its own:
/// it analyses the demo project's budget vs. actuals, which come from Estimating (budget) and posting (actuals).
/// So its Import() just ensures the shared CONS-DEMO project context exists, giving the cost-control pages a
/// project to open. For a populated cost breakdown, run the Estimating demo (a Bill of Quantities → budget) too.
/// Idempotent and message-free; reached from the assisted-setup wizard and the demoCostControl API action.
/// </summary>
codeunit 50033 "CONS Demo Cost Control"
{
    Access = Public;

    /// <summary>Ensure the shared demo project context exists so Cost Control has data to analyse. Idempotent.</summary>
    procedure Import()
    var
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        DemoFoundation.EnsureProjectContext();
    end;
}
