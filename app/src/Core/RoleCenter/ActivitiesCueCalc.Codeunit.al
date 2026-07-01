namespace Construction.Core;

using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;

codeunit 50025 "CONS Activities Cue Calc"
{
    Access = Internal;

    /// <summary>
    /// Computes the role center activity counts and returns them as a Page Background Task result,
    /// keyed by the cue field number. Runs in a read-only background session so the role center opens
    /// immediately and the tiles fill in asynchronously — never compute these counts synchronously on
    /// the page thread. The page (CONS Construction Activities) enqueues this and reads the result in
    /// OnPageBackgroundTaskCompleted.
    /// </summary>
    trigger OnRun()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        BoQHeader: Record "CONS BoQ Header";
        ProgBillingHeader: Record "CONS Progress Billing Header";
        SubcontractHeader: Record "CONS Subcontract Header";
        ChangeOrderHeader: Record "CONS Change Order Header";
        SubcClaimHeader: Record "CONS Subc Claim Header";
        Equipment: Record "CONS Equipment";
        Cue: Record "CONS Activities Cue";
        Results: Dictionary of [Text, Text];
    begin
        Job.SetRange("CONS Construction Project", true);
        Results.Add(Format(Cue.FieldNo("Construction Projects")), Format(Job.Count()));
        Job.SetRange(Status, Job.Status::Open);
        Results.Add(Format(Cue.FieldNo("Active Projects")), Format(Job.Count()));

        Results.Add(Format(Cue.FieldNo("Bills of Quantities")), Format(BoQHeader.Count()));
        Results.Add(Format(Cue.FieldNo("Progress Billing Applications")), Format(ProgBillingHeader.Count()));
        Results.Add(Format(Cue.FieldNo(Subcontracts)), Format(SubcontractHeader.Count()));
        Results.Add(Format(Cue.FieldNo("Change Orders")), Format(ChangeOrderHeader.Count()));
        Results.Add(Format(Cue.FieldNo("Subcontractor Claims")), Format(SubcClaimHeader.Count()));

        Results.Add(Format(Cue.FieldNo("Equipment Items")), Format(Equipment.Count()));
        Equipment.SetRange("In Maintenance", true);
        Results.Add(Format(Cue.FieldNo("Equipment In Maintenance")), Format(Equipment.Count()));

        JobTask.SetRange("CONS Scheduled", true);
        Results.Add(Format(Cue.FieldNo("Scheduled Tasks")), Format(JobTask.Count()));

        Page.SetBackgroundTaskResult(Results);
    end;
}
