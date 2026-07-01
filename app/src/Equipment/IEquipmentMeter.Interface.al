namespace Construction.Equipment;

interface "CONS IEquipmentMeter"
{
    Access = Public;

    /// <summary>Updates the parent equipment meter reading when a meter entry is inserted.</summary>
    /// <param name="EquipmentMeterEntry">The meter entry being inserted.</param>
    procedure Trigger_OnInsert(var EquipmentMeterEntry: Record "CONS Equipment Meter Entry");
}
