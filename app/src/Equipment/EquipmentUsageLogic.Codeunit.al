namespace Construction.Equipment;

codeunit 50431 "CONS Equipment Usage Logic" implements "CONS IEquipmentUsage"
{
    Access = Public;

    procedure Trigger_OnInsert(var EquipmentUsage: Record "CONS Equipment Usage")
    var
        ExistingUsage: Record "CONS Equipment Usage";
    begin
        if EquipmentUsage."Line No." <> 0 then
            exit;
        if ExistingUsage.FindLast() then
            EquipmentUsage."Line No." := ExistingUsage."Line No." + 10000
        else
            EquipmentUsage."Line No." := 10000;
    end;

    procedure Validate_EquipmentNo(var EquipmentUsage: Record "CONS Equipment Usage")
    var
        Equipment: Record "CONS Equipment";
        EquipmentRate: Record "CONS Equipment Rate";
        RateDate: Date;
        UnitCost: Decimal;
    begin
        EquipmentUsage."Unit of Measure Code" := '';
        EquipmentUsage."Unit Cost" := 0;
        if EquipmentUsage."Equipment No." = '' then begin
            RecalculateTotalCost(EquipmentUsage);
            exit;
        end;

        Equipment.Get(EquipmentUsage."Equipment No.");
        EquipmentUsage."Unit of Measure Code" := Equipment."Rate Unit of Measure";

        RateDate := EquipmentUsage."Posting Date";
        if RateDate = 0D then
            RateDate := WorkDate();

        UnitCost := EquipmentRate.FindUnitCost(EquipmentUsage."Equipment No.", EquipmentUsage."Project No.", RateDate);
        if UnitCost = 0 then
            UnitCost := Equipment."Cost Rate";
        EquipmentUsage."Unit Cost" := UnitCost;

        RecalculateTotalCost(EquipmentUsage);
    end;

    procedure Validate_Quantity(var EquipmentUsage: Record "CONS Equipment Usage")
    begin
        RecalculateTotalCost(EquipmentUsage);
    end;

    procedure Validate_UnitCost(var EquipmentUsage: Record "CONS Equipment Usage")
    begin
        RecalculateTotalCost(EquipmentUsage);
    end;

    local procedure RecalculateTotalCost(var EquipmentUsage: Record "CONS Equipment Usage")
    begin
        EquipmentUsage."Total Cost" := Round(EquipmentUsage.Quantity * EquipmentUsage."Unit Cost");
    end;
}
