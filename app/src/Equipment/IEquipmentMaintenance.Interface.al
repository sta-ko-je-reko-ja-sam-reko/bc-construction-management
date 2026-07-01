namespace Construction.Equipment;

interface "CONS IEquipmentMaintenance"
{
    Access = Public;

    /// <summary>Updates the parent equipment service and meter information when a maintenance record is inserted.</summary>
    /// <param name="EquipmentMaintenance">The maintenance record being inserted.</param>
    procedure Trigger_OnInsert(var EquipmentMaintenance: Record "CONS Equipment Maintenance");
}
