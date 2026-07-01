namespace Construction.Estimating;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

codeunit 50063 "CONS BoQ Line Logic" implements "CONS IBoQLine"
{
    Access = Public;

    procedure Trigger_OnInsert(var BoQLine: Record "CONS BoQ Line")
    var
        BoQHeader: Record "CONS BoQ Header";
    begin
        if not BoQHeader.Get(BoQLine."Document No.") then
            exit;
        if BoQLine."Markup %" = 0 then
            BoQLine."Markup %" := BoQHeader."Default Markup %";
    end;

    procedure Validate_LineType(var BoQLine: Record "CONS BoQ Line")
    begin
        UpdateAmounts(BoQLine);
    end;

    procedure Validate_Type(var BoQLine: Record "CONS BoQ Line"; xBoQLine: Record "CONS BoQ Line")
    begin
        if BoQLine.Type <> xBoQLine.Type then
            BoQLine."No." := '';
    end;

    procedure Validate_No(var BoQLine: Record "CONS BoQ Line")
    begin
        CopyFromReferencedRecord(BoQLine);
    end;

    procedure Validate_Amounts(var BoQLine: Record "CONS BoQ Line")
    begin
        UpdateAmounts(BoQLine);
    end;

    local procedure UpdateAmounts(var BoQLine: Record "CONS BoQ Line")
    begin
        if BoQLine."Line Type" <> BoQLine."Line Type"::Position then begin
            BoQLine."Total Cost" := 0;
            BoQLine."Unit Price" := 0;
            BoQLine."Total Price" := 0;
            exit;
        end;
        BoQLine."Total Cost" := Round(BoQLine.Quantity * BoQLine."Unit Cost");
        BoQLine."Unit Price" := BoQLine."Unit Cost" * (1 + BoQLine."Markup %" / 100);
        BoQLine."Total Price" := Round(BoQLine.Quantity * BoQLine."Unit Price");
    end;

    local procedure CopyFromReferencedRecord(var BoQLine: Record "CONS BoQ Line")
    var
        Resource: Record Resource;
        Item: Record Item;
        GLAccount: Record "G/L Account";
    begin
        case BoQLine.Type of
            BoQLine.Type::Resource:
                if Resource.Get(BoQLine."No.") then begin
                    BoQLine.Description := Resource.Name;
                    BoQLine."Unit of Measure Code" := Resource."Base Unit of Measure";
                    if BoQLine."Unit Cost" = 0 then
                        BoQLine.Validate("Unit Cost", Resource."Unit Cost");
                end;
            BoQLine.Type::Item:
                if Item.Get(BoQLine."No.") then begin
                    BoQLine.Description := Item.Description;
                    BoQLine."Unit of Measure Code" := Item."Base Unit of Measure";
                    if BoQLine."Unit Cost" = 0 then
                        BoQLine.Validate("Unit Cost", Item."Unit Cost");
                end;
            BoQLine.Type::"G/L Account":
                if GLAccount.Get(BoQLine."No.") then
                    BoQLine.Description := GLAccount.Name;
        end;
    end;
}
