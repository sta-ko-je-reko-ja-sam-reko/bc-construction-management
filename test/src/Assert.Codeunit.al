codeunit 50500 "CONS Assert"
{
    // Self-contained assertions so the test app builds without the AL Test Toolkit installed.
    // Swap for Microsoft "Library Assert" once the toolkit is guaranteed in CI/container.

    var
        AreEqualErr: Label 'AreEqual failed: expected ''%1'', actual ''%2'' (%3).', Comment = '%1 = expected, %2 = actual, %3 = context';
        IsTrueErr: Label 'IsTrue failed: %1.', Comment = '%1 = context';
        ExpectedErrorErr: Label 'ExpectedError failed: expected error containing ''%1'', actual ''%2''.', Comment = '%1 = expected substring, %2 = actual error text';

    procedure AreEqual(Expected: Decimal; Actual: Decimal; Context: Text)
    begin
        if Expected <> Actual then
            Error(AreEqualErr, Expected, Actual, Context);
    end;

    procedure AreEqualText(Expected: Text; Actual: Text; Context: Text)
    begin
        if Expected <> Actual then
            Error(AreEqualErr, Expected, Actual, Context);
    end;

    procedure IsTrue(Condition: Boolean; Context: Text)
    begin
        if not Condition then
            Error(IsTrueErr, Context);
    end;

    /// <summary>
    /// Asserts that the last error (captured after an `asserterror` statement) contains the
    /// expected substring. Call immediately after the `asserterror` that triggered it.
    /// </summary>
    procedure ExpectedError(ExpectedSubstring: Text)
    var
        ActualError: Text;
    begin
        ActualError := GetLastErrorText();
        if StrPos(ActualError, ExpectedSubstring) = 0 then
            Error(ExpectedErrorErr, ExpectedSubstring, ActualError);
    end;
}
