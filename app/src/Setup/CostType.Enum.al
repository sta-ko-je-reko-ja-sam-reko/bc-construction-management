namespace Construction.Setup;

enum 50000 "CONS Cost Type"
{
    Extensible = true;
    Caption = 'Construction Cost Type';

    value(0; Labor)
    {
        Caption = 'Labor';
    }
    value(1; Material)
    {
        Caption = 'Material';
    }
    value(2; Equipment)
    {
        Caption = 'Equipment';
    }
    value(3; Subcontract)
    {
        Caption = 'Subcontract';
    }
    value(4; "Other")
    {
        Caption = 'Other';
    }
}
