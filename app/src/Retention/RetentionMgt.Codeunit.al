namespace Construction.Retention;

codeunit 50205 "CONS Retention Mgt"
{
    Access = Public;

    /// <summary>
    /// Computes the retention amount to withhold from a billed amount. Pure (no DB) so it is
    /// unit-testable in isolation. Rounded to currency precision via the standard amount rounding.
    /// </summary>
    /// <param name="BilledAmount">The amount certified/billed this period.</param>
    /// <param name="RetentionPct">The retention percentage (0..100).</param>
    /// <returns>The amount to withhold, rounded to the G/L Setup amount precision.</returns>
    internal procedure CalcRetention(BilledAmount: Decimal; RetentionPct: Decimal): Decimal
    begin
        if RetentionPct <= 0 then
            exit(0);
        exit(Round(BilledAmount * RetentionPct / 100));
    end;

    /// <summary>Records a withheld-retention entry (positive amount) for a posted progress invoice.</summary>
    internal procedure InsertWithheld(ProjectNo: Code[20]; Direction: Enum "CONS Retention Direction"; DocumentNo: Code[20]; PostingDate: Date; AccountNo: Code[20]; GLAccountNo: Code[20]; ApplicationNo: Integer; Amount: Decimal; DueDate: Date): Integer
    var
        RetentionEntry: Record "CONS Retention Entry";
    begin
        if Amount = 0 then
            exit(0);
        RetentionEntry.Init();
        RetentionEntry.Direction := Direction;
        RetentionEntry."Entry Type" := RetentionEntry."Entry Type"::Withheld;
        RetentionEntry."Project No." := ProjectNo;
        RetentionEntry."Document No." := DocumentNo;
        RetentionEntry."Posting Date" := PostingDate;
        RetentionEntry."Account No." := AccountNo;
        RetentionEntry."G/L Account No." := GLAccountNo;
        RetentionEntry."Application No." := ApplicationNo;
        RetentionEntry.Amount := Abs(Amount);
        RetentionEntry."Due Date" := DueDate;
        RetentionEntry.Open := true;
        RetentionEntry.Insert(true);
        exit(RetentionEntry."Entry No.");
    end;

    /// <summary>Records a released-retention entry (negative amount), reducing the outstanding balance.</summary>
    internal procedure InsertReleased(ProjectNo: Code[20]; Direction: Enum "CONS Retention Direction"; DocumentNo: Code[20]; PostingDate: Date; AccountNo: Code[20]; GLAccountNo: Code[20]; ApplicationNo: Integer; Amount: Decimal): Integer
    var
        RetentionEntry: Record "CONS Retention Entry";
    begin
        if Amount = 0 then
            exit(0);
        RetentionEntry.Init();
        RetentionEntry.Direction := Direction;
        RetentionEntry."Entry Type" := RetentionEntry."Entry Type"::Released;
        RetentionEntry."Project No." := ProjectNo;
        RetentionEntry."Document No." := DocumentNo;
        RetentionEntry."Posting Date" := PostingDate;
        RetentionEntry."Account No." := AccountNo;
        RetentionEntry."G/L Account No." := GLAccountNo;
        RetentionEntry."Application No." := ApplicationNo;
        RetentionEntry.Amount := -Abs(Amount);
        RetentionEntry.Open := false;
        RetentionEntry.Insert(true);
        exit(RetentionEntry."Entry No.");
    end;

    /// <summary>Returns the outstanding (withheld minus released) retention for a project and direction.</summary>
    internal procedure OutstandingRetention(ProjectNo: Code[20]; Direction: Enum "CONS Retention Direction"): Decimal
    var
        RetentionEntry: Record "CONS Retention Entry";
    begin
        RetentionEntry.SetRange("Project No.", ProjectNo);
        RetentionEntry.SetRange(Direction, Direction);
        RetentionEntry.CalcSums(Amount);
        exit(RetentionEntry.Amount);
    end;

    /// <summary>
    /// Returns the outstanding retention for a project and direction limited to one account
    /// (a vendor for payable retention, a customer for receivable retention).
    /// </summary>
    internal procedure OutstandingForAccount(ProjectNo: Code[20]; Direction: Enum "CONS Retention Direction"; AccountNo: Code[20]): Decimal
    var
        RetentionEntry: Record "CONS Retention Entry";
    begin
        RetentionEntry.SetRange("Project No.", ProjectNo);
        RetentionEntry.SetRange(Direction, Direction);
        RetentionEntry.SetRange("Account No.", AccountNo);
        RetentionEntry.CalcSums(Amount);
        exit(RetentionEntry.Amount);
    end;
}
