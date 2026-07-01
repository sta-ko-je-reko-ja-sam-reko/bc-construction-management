namespace Construction.Estimating;

permissionset 50060 "CONS Est - Edit"
{
    Assignable = true;
    Caption = 'Construction Estimating - Edit', Locked = true;

    Permissions =
        tabledata "CONS BoQ Header" = RIMD,
        tabledata "CONS BoQ Line" = RIMD,
        table "CONS BoQ Header" = X,
        table "CONS BoQ Line" = X,
        page "CONS Bill of Quantities" = X,
        page "CONS BoQ Subform" = X,
        page "CONS Bill of Quantities List" = X,
        page "CONS BoQ API" = X,
        page "CONS BoQ Line API" = X,
        tabledata "CONS Estimating Setup" = RIMD,
        table "CONS Estimating Setup" = X,
        page "CONS Estimating Setup" = X,
        codeunit "CONS BoQ Create Budget" = X,
        codeunit "CONS BoQ Line Logic" = X,
        codeunit "CONS BoQ Header Logic" = X;
}
