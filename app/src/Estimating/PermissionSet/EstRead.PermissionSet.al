namespace Construction.Estimating;

permissionset 50061 "CONS Est - Read"
{
    Assignable = true;
    Caption = 'Construction Estimating - Read', Locked = true;

    Permissions =
        tabledata "CONS BoQ Header" = R,
        tabledata "CONS BoQ Line" = R,
        table "CONS BoQ Header" = X,
        table "CONS BoQ Line" = X,
        page "CONS Bill of Quantities" = X,
        page "CONS BoQ Subform" = X,
        page "CONS Bill of Quantities List" = X,
        page "CONS BoQ API" = X,
        page "CONS BoQ Line API" = X,
        tabledata "CONS Estimating Setup" = R,
        table "CONS Estimating Setup" = X,
        page "CONS Estimating Setup" = X,
        codeunit "CONS BoQ Line Logic" = X,
        codeunit "CONS BoQ Header Logic" = X;
}
