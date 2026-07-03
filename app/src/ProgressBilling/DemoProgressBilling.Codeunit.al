namespace Construction.ProgressBilling;

using Construction.Setup;

/// <summary>
/// Progress Billing demo seeder — a context-only importer. A progress billing application is created against a
/// project and then seeded from that project's lines, so the meaningful demo is driven interactively from the
/// CONS-DEMO project (create an application, then Seed from Project). Import() therefore ensures the shared
/// CONS-DEMO project context exists, giving the progress-billing pages a project to work from. Idempotent and
/// message-free; reached from the assisted-setup wizard and the demoProgressBilling API action.
/// </summary>
codeunit 50034 "CONS Demo Progress Billing"
{
    Access = Public;

    /// <summary>Ensure the shared demo project context exists so Progress Billing has a project to bill. Idempotent.</summary>
    procedure Import()
    var
        DemoFoundation: Codeunit "CONS Demo Foundation";
    begin
        DemoFoundation.EnsureProjectContext();
    end;
}
