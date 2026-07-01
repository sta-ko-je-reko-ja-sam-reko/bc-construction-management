namespace Construction.Equipment;

interface "CONS IEquipmentUsage"
{
    Access = Public;

    /// <summary>Assigns the next line number when a new equipment usage line is inserted.</summary>
    /// <param name="EquipmentUsage">The line being inserted.</param>
    procedure Trigger_OnInsert(var EquipmentUsage: Record "CONS Equipment Usage");

    /// <summary>Defaults the unit of measure and unit cost from the equipment and rates, then recomputes the total cost.</summary>
    /// <param name="EquipmentUsage">The line whose equipment was validated.</param>
    procedure Validate_EquipmentNo(var EquipmentUsage: Record "CONS Equipment Usage");

    /// <summary>Recomputes the total cost when the quantity changes.</summary>
    /// <param name="EquipmentUsage">The line whose quantity was validated.</param>
    procedure Validate_Quantity(var EquipmentUsage: Record "CONS Equipment Usage");

    /// <summary>Recomputes the total cost when the unit cost changes.</summary>
    /// <param name="EquipmentUsage">The line whose unit cost was validated.</param>
    procedure Validate_UnitCost(var EquipmentUsage: Record "CONS Equipment Usage");
}
