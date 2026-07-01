namespace Construction.Equipment;

codeunit 50433 "CONS Equipment Meter Logic" implements "CONS IEquipmentMeter"
{
    Access = Public;

    procedure Trigger_OnInsert(var EquipmentMeterEntry: Record "CONS Equipment Meter Entry")
    var
        Equipment: Record "CONS Equipment";
    begin
        if EquipmentMeterEntry."Equipment No." = '' then
            exit;

        Equipment.SetLoadFields("Meter Reading");
        if not Equipment.Get(EquipmentMeterEntry."Equipment No.") then
            exit;

        Equipment."Meter Reading" := EquipmentMeterEntry."Meter Reading";
        Equipment.Modify(true);
    end;
}
