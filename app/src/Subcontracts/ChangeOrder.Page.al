namespace Construction.Subcontracts;

using Construction.Core;

page 50277 "CONS Change Order"
{
    PageType = Document;
    ApplicationArea = CONSSubcontracts;
    UsageCategory = None;
    SourceTable = "CONS Change Order Header";
    Caption = 'Change Order';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field("Project No."; Rec."Project No.") { }
                field("Change Type"; Rec."Change Type") { }
                field("Subcontract No."; Rec."Subcontract No.") { }
                field(Description; Rec.Description) { }
                field(Reason; Rec.Reason) { }
                field("Document Date"; Rec."Document Date") { }
                field(Status; Rec.Status) { }
            }
            part(Lines; "CONS Change Order Subform")
            {
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Totals)
            {
                field("Total Amount"; Rec."Total Amount") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReleaseChangeOrder)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                ToolTip = 'Applies the change order: owner changes raise the project contract value, subcontract changes add variation lines to the subcontract, and the lines push to the project budget. When an approval workflow is enabled, send it for approval instead.';

                trigger OnAction()
                var
                    ChangeOrderApproval: Codeunit "CONS Change Order Approval";
                begin
                    if ChangeOrderApproval.IsWorkflowEnabled(Rec) then
                        Error(UseApprovalErr);
                    Rec.Apply();
                    CurrPage.Update(false);
                end;
            }
            action(SendApprovalRequest)
            {
                Caption = 'Send Approval Request';
                Image = SendApprovalRequest;
                ToolTip = 'Sends the change order into its approval workflow.';

                trigger OnAction()
                var
                    ChangeOrderApproval: Codeunit "CONS Change Order Approval";
                begin
                    if not ChangeOrderApproval.IsWorkflowEnabled(Rec) then
                        Error(NoWorkflowErr);
                    ChangeOrderApproval.SendForApproval(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelApprovalRequest)
            {
                Caption = 'Cancel Approval Request';
                Image = CancelApprovalRequest;
                ToolTip = 'Cancels the pending approval request for the change order.';

                trigger OnAction()
                var
                    ChangeOrderApproval: Codeunit "CONS Change Order Approval";
                begin
                    ChangeOrderApproval.CancelApprovalRequest(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ReleaseChangeOrder_Promoted; ReleaseChangeOrder) { }
                actionref(SendApprovalRequest_Promoted; SendApprovalRequest) { }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "CONS License Mgt.";
    begin
        LicenseMgt.CheckModuleLicensed(Enum::"CONS Module"::Subcontracts);
    end;

    var
        UseApprovalErr: Label 'An approval workflow is enabled for change orders. Use Send Approval Request instead of Release.';
        NoWorkflowErr: Label 'No change order approval workflow is enabled. Use Release to apply the change order directly.';
}

