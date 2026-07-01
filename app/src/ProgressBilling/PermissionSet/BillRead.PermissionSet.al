namespace Construction.ProgressBilling;

using Construction.Retention;

permissionset 50162 "CONS Bill - Read"
{
    Assignable = true;
    Caption = 'Construction Progress Billing - Read', Locked = true;

    Permissions =
        tabledata "CONS Progress Billing Header" = R,
        tabledata "CONS Progress Billing Line" = R,
        tabledata "CONS Retention Entry" = R,
        table "CONS Progress Billing Header" = X,
        table "CONS Progress Billing Line" = X,
        table "CONS Retention Entry" = X,
        page "CONS Progress Billing" = X,
        page "CONS Prog. Billing Subform" = X,
        page "CONS Progress Billing List" = X,
        page "CONS Retention Entries" = X,
        page "CONS Progress Billing API" = X,
        page "CONS Progress Billing Line API" = X,
        page "CONS Retention Entry API" = X,
        page "CONS Sales Invoice API" = X,
        page "CONS Sales Order API" = X,
        tabledata "CONS Progress Billing Setup" = R,
        table "CONS Progress Billing Setup" = X,
        page "CONS Progress Billing Setup" = X,
        report "CONS Payment Certificate" = X,
        codeunit "CONS Prog. Bill Header Logic" = X,
        codeunit "CONS Prog. Billing Line Logic" = X,
        codeunit "CONS Prog. Billing Seed" = X,
        codeunit "CONS Prog. Billing Invoice" = X,
        codeunit "CONS Retention Mgt" = X,
        codeunit "CONS Retention Logic" = X,
        codeunit "CONS Retention Release" = X,
        codeunit "CONS Sales Retention Events" = X;
}
