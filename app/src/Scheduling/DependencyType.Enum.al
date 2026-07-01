namespace Construction.Scheduling;

enum 50460 "CONS Dependency Type"
{
    Extensible = true;

    value(0; "Finish-to-Start")
    {
        Caption = 'Finish-to-start';
    }
    value(1; "Start-to-Start")
    {
        Caption = 'Start-to-start';
    }
    value(2; "Finish-to-Finish")
    {
        Caption = 'Finish-to-finish';
    }
    value(3; "Start-to-Finish")
    {
        Caption = 'Start-to-finish';
    }
}
