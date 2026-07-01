namespace Construction.Equipment;

codeunit 50432 "CONS Equipment Maint. Logic" implements "CONS IEquipmentMaintenance"
{
    Access = Public;

    procedure Trigger_OnInsert(var EquipmentMaintenance: Record "CONS Equipment Maintenance")
    var
        Equipment: Record "CONS Equipment";
    begin
        if EquipmentMaintenance."Equipment No." = '' then
            exit;

        Equipment.SetLoadFields("Last Service Date", "Next Service Date", "Next Service Meter", "Meter Reading");
        if not Equipment.Get(EquipmentMaintenance."Equipment No.") then
            exit;

        Equipment."Last Service Date" := EquipmentMaintenance."Maintenance Date";
        if EquipmentMaintenance."Next Service Date" <> 0D then
            Equipment."Next Service Date" := EquipmentMaintenance."Next Service Date";
        if EquipmentMaintenance."Next Service Meter" <> 0 then
            Equipment."Next Service Meter" := EquipmentMaintenance."Next Service Meter";
        if EquipmentMaintenance."Meter Reading" <> 0 then
            Equipment."Meter Reading" := EquipmentMaintenance."Meter Reading";
        Equipment.Modify(true);
    end;
}
