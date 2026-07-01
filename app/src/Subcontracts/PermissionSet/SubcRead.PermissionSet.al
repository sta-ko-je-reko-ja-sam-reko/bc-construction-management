namespace Construction.Subcontracts;

using Construction.Retention;

permissionset 50195 "CONS Subc - Read"
{
    Assignable = true;
    Caption = 'Construction Subcontracts - Read', Locked = true;

    Permissions =
        tabledata "CONS Subcontract Header" = R,
        tabledata "CONS Subcontract Line" = R,
        tabledata "CONS Subc Claim Header" = R,
        tabledata "CONS Subc Claim Line" = R,
        tabledata "CONS Change Order Header" = R,
        tabledata "CONS Change Order Line" = R,
        table "CONS Subcontract Header" = X,
        table "CONS Subcontract Line" = X,
        table "CONS Subc Claim Header" = X,
        table "CONS Subc Claim Line" = X,
        table "CONS Change Order Header" = X,
        table "CONS Change Order Line" = X,
        page "CONS Subcontract" = X,
        page "CONS Subcontract Subform" = X,
        page "CONS Subcontract List" = X,
        page "CONS Subc Claim" = X,
        page "CONS Subc Claim Subform" = X,
        page "CONS Subc Claim List" = X,
        page "CONS Change Order" = X,
        page "CONS Change Order Subform" = X,
        page "CONS Change Order List" = X,
        page "CONS Subcontract API" = X,
        page "CONS Subcontract Line API" = X,
        page "CONS Subc Claim API" = X,
        page "CONS Subc Claim Line API" = X,
        page "CONS Change Order API" = X,
        page "CONS Change Order Line API" = X,
        page "CONS Purchase Order API" = X,
        page "CONS Purchase Invoice API" = X,
        tabledata "CONS Retention Entry" = R,
        table "CONS Retention Entry" = X,
        page "CONS Retention Entries" = X,
        tabledata "CONS Subcontracts Setup" = R,
        table "CONS Subcontracts Setup" = X,
        page "CONS Subcontracts Setup" = X,
        codeunit "CONS Subcontract Header Logic" = X,
        codeunit "CONS Subcontract Line Logic" = X,
        codeunit "CONS Subc Claim Hdr Logic" = X,
        codeunit "CONS Subc Claim Line Logic" = X,
        codeunit "CONS Subc Claim Seed" = X,
        codeunit "CONS Subc Claim Invoice" = X,
        codeunit "CONS Subc Retention Release" = X,
        codeunit "CONS Change Order Hdr Logic" = X,
        codeunit "CONS Change Order Workflow" = X,
        codeunit "CONS Change Order Approval" = X,
        codeunit "CONS Change Order Wf Demo" = X,
        codeunit "CONS Retention Mgt" = X,
        codeunit "CONS Retention Logic" = X,
        codeunit "CONS Purch Retention Events" = X;
}
