namespace Construction.Equipment;

using Construction.Core;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Posting;

codeunit 50430 "CONS Equipment Usage-Post"
{
    Access = Public;

    /// <summary>
    /// Posts a single equipment usage line to the project ledger by building and posting a standard
    /// Job Journal Line as a Resource (the equipment's linked resource). The usage line is deleted
    /// after a successful post.
    /// </summary>
    /// <param name="EquipmentUsage">The usage line to post.</param>
    procedure PostUsage(var EquipmentUsage: Record "CONS Equipment Usage")
    var
        Equipment: Record "CONS Equipment";
        JobJournalLine: Record "Job Journal Line";
        JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
        FeatureMgt: Codeunit "CONS Feature Mgt.";
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"CONS Feature"::Equipment);
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::"Equipment & Plant");

        EquipmentUsage.TestField("Equipment No.");
        EquipmentUsage.TestField("Project No.");
        EquipmentUsage.TestField(Quantity);
        EquipmentUsage.TestField("Posting Date");

        Equipment.Get(EquipmentUsage."Equipment No.");
        Equipment.TestField("Resource No.");
        if Equipment."In Maintenance" then
            Error(InMaintenanceErr, Equipment."No.");

        JobJournalLine.Init();
        JobJournalLine."Line No." := 10000;
        JobJournalLine.Validate("Job No.", EquipmentUsage."Project No.");
        if EquipmentUsage."Job Task No." <> '' then
            JobJournalLine.Validate("Job Task No.", EquipmentUsage."Job Task No.");
        JobJournalLine."Posting Date" := EquipmentUsage."Posting Date";
        JobJournalLine."Document No." := Format(EquipmentUsage."Posting Date", 0, '<Year4><Month,2><Day,2>');
        JobJournalLine.Validate(Type, JobJournalLine.Type::Resource);
        JobJournalLine.Validate("No.", Equipment."Resource No.");
        if EquipmentUsage."Unit of Measure Code" <> '' then
            JobJournalLine.Validate("Unit of Measure Code", EquipmentUsage."Unit of Measure Code");
        JobJournalLine.Validate(Quantity, EquipmentUsage.Quantity);
        if EquipmentUsage."Unit Cost" <> 0 then
            JobJournalLine.Validate("Unit Cost", EquipmentUsage."Unit Cost");
        JobJournalLine.Description := BuildDescription(Equipment, EquipmentUsage);

        JobJnlPostLine.RunWithCheck(JobJournalLine);

        EquipmentUsage.Delete(true);
    end;

    /// <summary>Posts every equipment usage line currently in the worksheet.</summary>
    procedure PostBatch()
    var
        EquipmentUsage: Record "CONS Equipment Usage";
        Posted: Integer;
    begin
        if not EquipmentUsage.FindSet() then
            Error(NothingToPostErr);

        repeat
            PostUsage(EquipmentUsage);
            Posted += 1;
        until EquipmentUsage.Next() = 0;

        Message(PostedMsg, Posted);
    end;

    local procedure BuildDescription(Equipment: Record "CONS Equipment"; EquipmentUsage: Record "CONS Equipment Usage"): Text[100]
    begin
        if EquipmentUsage.Description <> '' then
            exit(EquipmentUsage.Description);
        exit(CopyStr(StrSubstNo(DefaultDescriptionLbl, Equipment."No.", Equipment.Description), 1, 100));
    end;

    var
        InMaintenanceErr: Label 'Equipment %1 is in maintenance and cannot be used.', Comment = '%1 = equipment no.';
        NothingToPostErr: Label 'There are no equipment usage lines to post.';
        PostedMsg: Label '%1 equipment usage line(s) were posted.', Comment = '%1 = number of posted lines';
        DefaultDescriptionLbl: Label 'Equipment %1 %2', Comment = '%1 = equipment no., %2 = equipment description';
}
