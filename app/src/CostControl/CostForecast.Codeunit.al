namespace Construction.CostControl;

using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Document;

codeunit 50123 "CONS Cost Forecast"
{
    Access = Public;

    /// <summary>
    /// Computes cost-control figures for a project task: budget (schedule), committed (open
    /// purchase amounts), actual (usage), cost-to-complete (ETC), estimate-at-completion (EAC),
    /// variance, and % complete. Point-in-time; no values are stored.
    /// </summary>
    internal procedure CalcForecast(var JobTask: Record "Job Task"; var Budget: Decimal; var Committed: Decimal; var Actual: Decimal; var ETC: Decimal; var EAC: Decimal; var Variance: Decimal; var PctComplete: Decimal)
    begin
        JobTask.CalcFields("Schedule (Total Cost)", "Usage (Total Cost)");
        Budget := JobTask."Schedule (Total Cost)";
        Actual := JobTask."Usage (Total Cost)";
        Committed := CommittedCost(JobTask);

        PctComplete := PercentComplete(JobTask, Budget, Actual);

        Compute(Budget, Actual, Committed, ETC, EAC, Variance);
    end;

    /// <summary>Pure forecast math (no data access) — unit-testable in isolation.</summary>
    /// <param name="Budget">The task's budget (schedule) cost.</param>
    /// <param name="Actual">The task's actual (usage) cost.</param>
    /// <param name="Committed">The task's committed (open purchase) cost.</param>
    /// <param name="ETC">Returns the estimate-to-complete (clamped at zero).</param>
    /// <param name="EAC">Returns the estimate-at-completion.</param>
    /// <param name="Variance">Returns budget minus estimate-at-completion.</param>
    internal procedure Compute(Budget: Decimal; Actual: Decimal; Committed: Decimal; var ETC: Decimal; var EAC: Decimal; var Variance: Decimal)
    begin
        ETC := Budget - Actual - Committed;
        if ETC < 0 then
            ETC := 0;
        EAC := Actual + Committed + ETC;
        Variance := Budget - EAC;
    end;

    /// <summary>Sum of outstanding (not yet invoiced) purchase amounts linked to the task.</summary>
    /// <param name="JobTask">The project task whose committed cost is summed.</param>
    /// <returns>The outstanding purchase amount in LCY.</returns>
    internal procedure CommittedCost(var JobTask: Record "Job Task"): Decimal
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Job No.", JobTask."Job No.");
        PurchaseLine.SetRange("Job Task No.", JobTask."Job Task No.");
        PurchaseLine.CalcSums("Outstanding Amount (LCY)");
        exit(PurchaseLine."Outstanding Amount (LCY)");
    end;

    local procedure PercentComplete(var JobTask: Record "Job Task"; Budget: Decimal; Actual: Decimal): Decimal
    begin
        if JobTask."CONS % Complete" > 0 then
            exit(JobTask."CONS % Complete");
        if Budget <> 0 then
            exit(Round(Actual / Budget * 100, 0.01));
        exit(0);
    end;
}
