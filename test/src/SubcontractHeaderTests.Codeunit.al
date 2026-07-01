codeunit 50515 "CONS Subcontract Header Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure ValidateVendorNo_Unchanged_LeavesRetention()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        xSubcontractHeader: Record "CONS Subcontract Header";
        Logic: Codeunit "CONS Subcontract Header Logic";
    begin
        // [GIVEN] the vendor is unchanged between Rec and xRec (early-exit guard, no setup read)
        SubcontractHeader."Buy-from Vendor No." := 'V-001';
        SubcontractHeader."Retention %" := 7.5;
        xSubcontractHeader."Buy-from Vendor No." := 'V-001';
        // [WHEN] the vendor validation runs
        Logic.Validate_VendorNo(SubcontractHeader, xSubcontractHeader);
        // [THEN] the existing retention % is left untouched (no default applied)
        Assert.AreEqual(7.5, SubcontractHeader."Retention %", 'Retention % unchanged when vendor is unchanged');
    end;

    [Test]
    procedure ValidateVendorNo_RetentionAlreadySet_KeepsIt()
    var
        SubcontractHeader: Record "CONS Subcontract Header";
        xSubcontractHeader: Record "CONS Subcontract Header";
        Logic: Codeunit "CONS Subcontract Header Logic";
    begin
        // [GIVEN] a new vendor is chosen but a retention % is already entered (guard before setup read)
        SubcontractHeader."Buy-from Vendor No." := 'V-002';
        SubcontractHeader."Retention %" := 10;
        xSubcontractHeader."Buy-from Vendor No." := 'V-001';
        // [WHEN] the vendor validation runs
        Logic.Validate_VendorNo(SubcontractHeader, xSubcontractHeader);
        // [THEN] the manually entered retention % is preserved (setup default not pulled)
        Assert.AreEqual(10, SubcontractHeader."Retention %", 'Existing non-zero retention % is preserved on vendor change');
    end;

    [Test]
    procedure ValidateSubcontractNo_Unchanged_NoCopy()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] the subcontract is unchanged between Rec and xRec (early-exit, no header lookup)
        SubcClaimHeader."Subcontract No." := 'SC-001';
        SubcClaimHeader."Project No." := 'PRE-SET';
        xSubcClaimHeader."Subcontract No." := 'SC-001';
        // [WHEN] the subcontract validation runs
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] previously assigned project is not overwritten
        Assert.AreEqualText('PRE-SET', SubcClaimHeader."Project No.", 'Project No. untouched when subcontract is unchanged');
    end;

    [Test]
    procedure ValidateSubcontractNo_Blank_NoCopy()
    var
        SubcClaimHeader: Record "CONS Subc Claim Header";
        xSubcClaimHeader: Record "CONS Subc Claim Header";
        Logic: Codeunit "CONS Subc Claim Hdr Logic";
    begin
        // [GIVEN] the subcontract is cleared (set to blank); guard exits before any header lookup
        SubcClaimHeader."Subcontract No." := '';
        SubcClaimHeader."Project No." := 'PRE-SET';
        xSubcClaimHeader."Subcontract No." := 'SC-001';
        // [WHEN] the subcontract validation runs
        Logic.Validate_SubcontractNo(SubcClaimHeader, xSubcClaimHeader);
        // [THEN] no copy happens, project is left as-is
        Assert.AreEqualText('PRE-SET', SubcClaimHeader."Project No.", 'Project No. untouched when subcontract is blanked');
    end;

    [Test]
    procedure ClaimLineTriggerOnInsert_RetentionSet_NotOverwritten()
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line that already carries a retention % (guard exits before reading the header)
        SubcClaimLine."Document No." := 'CLAIM-T';
        SubcClaimLine."Line No." := 10000;
        SubcClaimLine."Retention %" := 8;
        // [WHEN] the insert trigger logic runs
        Logic.Trigger_OnInsert(SubcClaimLine);
        // [THEN] the line keeps its own retention % (header default not inherited)
        Assert.AreEqual(8, SubcClaimLine."Retention %", 'Line retention % is kept when already non-zero on insert');
    end;

    [Test]
    procedure ClaimLineValidateAmounts_ZeroScheduledValue_PercentIsZero()
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line with no scheduled value (division-by-zero guard path)
        SubcClaimLine."Scheduled Value" := 0;
        SubcClaimLine."Previous Amount" := 500;
        SubcClaimLine."This Period Amount" := 250;
        SubcClaimLine."Retention %" := 0;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(SubcClaimLine);
        // [THEN] completed-to-date still accrues but % complete is forced to zero
        Assert.AreEqual(750, SubcClaimLine."Completed To Date", 'Completed To Date = previous + this period');
        Assert.AreEqual(0, SubcClaimLine."% Complete", '% Complete = 0 when scheduled value is zero');
    end;

    [Test]
    procedure ClaimLineValidateAmounts_ZeroRetention_NetEqualsPeriod()
    var
        SubcClaimLine: Record "CONS Subc Claim Line";
        Logic: Codeunit "CONS Subc Claim Line Logic";
    begin
        // [GIVEN] a claim line with a 0% retention rate
        SubcClaimLine."Scheduled Value" := 4000;
        SubcClaimLine."Previous Amount" := 0;
        SubcClaimLine."This Period Amount" := 1000;
        SubcClaimLine."Retention %" := 0;
        // [WHEN] amounts are recalculated
        Logic.Validate_Amounts(SubcClaimLine);
        // [THEN] no retention is withheld and net payable equals the period amount
        Assert.AreEqual(0, SubcClaimLine."Retention This Period", 'No retention withheld at 0%');
        Assert.AreEqual(1000, SubcClaimLine."Net Payable This Period", 'Net payable equals period amount when retention is 0%');
        Assert.AreEqual(25, SubcClaimLine."% Complete", '% Complete = 1000 / 4000 * 100');
    end;
}
