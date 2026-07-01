codeunit 50510 "CONS Equipment Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure ValidateQuantity_ComputesTotalCost()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] an equipment usage line: quantity 8, unit cost 125
        Usage.Quantity := 8;
        Usage."Unit Cost" := 125;
        // [WHEN] the quantity is validated (logic tested directly — no database)
        Logic.Validate_Quantity(Usage);
        // [THEN] total cost = quantity * unit cost
        Assert.AreEqual(1000, Usage."Total Cost", 'Total Cost = quantity * unit cost');
    end;

    [Test]
    procedure ValidateUnitCost_ComputesTotalCost()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] an equipment usage line: quantity 3, unit cost 50
        Usage.Quantity := 3;
        Usage."Unit Cost" := 50;
        // [WHEN] the unit cost is validated (logic tested directly — no database)
        Logic.Validate_UnitCost(Usage);
        // [THEN] total cost = quantity * unit cost
        Assert.AreEqual(150, Usage."Total Cost", 'Total Cost = quantity * unit cost');
    end;

    [Test]
    procedure ValidateUnitCost_Rounds()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] a usage line whose total is not a whole number (2.5 * 3.33 = 8.325)
        Usage.Quantity := 2.5;
        Usage."Unit Cost" := 3.33;
        // [WHEN] the unit cost is validated
        Logic.Validate_UnitCost(Usage);
        // [THEN] the total cost is rounded to amount precision (0.01): 8.325 -> 8.33
        Assert.AreEqual(8.33, Usage."Total Cost", 'Total Cost is rounded to amount precision');
    end;

    [Test]
    procedure ValidateEquipmentNo_BlankEquipment_ClearsAndRecalculates()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] a usage line with a quantity but no equipment, carrying a stale unit cost
        Usage."Equipment No." := '';
        Usage.Quantity := 5;
        Usage."Unit Cost" := 99;
        Usage."Unit of Measure Code" := 'HOUR';
        // [WHEN] the (blank) equipment no. is validated
        Logic.Validate_EquipmentNo(Usage);
        // [THEN] unit cost and unit of measure are cleared and total cost falls to zero
        Assert.AreEqual(0, Usage."Unit Cost", 'Unit Cost cleared when equipment is blank');
        Assert.AreEqualText('', Usage."Unit of Measure Code", 'Unit of Measure cleared when equipment is blank');
        Assert.AreEqual(0, Usage."Total Cost", 'Total Cost recalculated to 0 when equipment is blank');
    end;

    [Test]
    procedure UsageOnInsert_FirstLine_GetsTenThousand()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] no equipment usage lines exist and a new line with no line no.
        Usage.DeleteAll();
        Clear(Usage);
        // [WHEN] the insert trigger logic assigns the line no.
        Logic.Trigger_OnInsert(Usage);
        // [THEN] the first line gets line no. 10000
        Assert.AreEqual(10000, Usage."Line No.", 'first usage line no. = 10000');
    end;

    [Test]
    procedure UsageOnInsert_NextLine_IncrementsByTenThousand()
    var
        Existing: Record "CONS Equipment Usage";
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] an existing usage line with line no. 10000
        Existing.DeleteAll();
        Existing."Line No." := 10000;
        Existing.Insert();
        Clear(Usage);
        // [WHEN] the insert trigger logic assigns the line no. of a new line
        Logic.Trigger_OnInsert(Usage);
        // [THEN] the new line continues from the last line + 10000
        Assert.AreEqual(20000, Usage."Line No.", 'next usage line no. = last + 10000');
    end;

    [Test]
    procedure UsageOnInsert_LineNoAlreadySet_IsKept()
    var
        Usage: Record "CONS Equipment Usage";
        Logic: Codeunit "CONS Equipment Usage Logic";
    begin
        // [GIVEN] a usage line that already carries an explicit line no.
        Usage."Line No." := 55000;
        // [WHEN] the insert trigger logic runs
        Logic.Trigger_OnInsert(Usage);
        // [THEN] the explicit line no. is left untouched
        Assert.AreEqual(55000, Usage."Line No.", 'explicit line no. is preserved');
    end;

    [Test]
    procedure FindUnitCost_ProjectRate_PreferredOverBlankProject()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] a blank-project rate and a project-specific rate for the same equipment and date
        Rate.DeleteAll();
        InsertRate('EQ01', '', 20260101D, 100, 0);
        InsertRate('EQ01', 'PROJ-A', 20260101D, 150, 0);
        // [WHEN] the unit cost is resolved for that project on a later date
        // [THEN] the project-specific rate wins over the blank-project rate
        Assert.AreEqual(150, Rate.FindUnitCost('EQ01', 'PROJ-A', 20260601D), 'project rate preferred over blank-project rate');
    end;

    [Test]
    procedure FindUnitCost_FallsBackToBlankProjectRate()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] only a blank-project rate exists for the equipment
        Rate.DeleteAll();
        InsertRate('EQ02', '', 20260101D, 100, 0);
        // [WHEN] the unit cost is resolved for a project that has no specific rate
        // [THEN] the blank-project rate is returned
        Assert.AreEqual(100, Rate.FindUnitCost('EQ02', 'PROJ-B', 20260601D), 'falls back to blank-project rate');
    end;

    [Test]
    procedure FindUnitCost_PicksLatestStartingDateOnOrBeforeDate()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] two blank-project rates with different starting dates
        Rate.DeleteAll();
        InsertRate('EQ03', '', 20260101D, 100, 0);
        InsertRate('EQ03', '', 20260301D, 130, 0);
        // [WHEN] the unit cost is resolved on a date after the later starting date
        // [THEN] the latest starting date on or before the date is used
        Assert.AreEqual(130, Rate.FindUnitCost('EQ03', '', 20260401D), 'latest starting date on or before the date wins');
    end;

    [Test]
    procedure FindUnitCost_NoRate_ReturnsZero()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] no rates for the equipment
        Rate.DeleteAll();
        // [WHEN] the unit cost is resolved
        // [THEN] zero is returned so the caller can fall back to the equipment default
        Assert.AreEqual(0, Rate.FindUnitCost('EQ04', 'PROJ-C', 20260601D), 'no rate returns 0');
    end;

    [Test]
    procedure FindUnitCost_RateAfterDate_IsIgnored()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] a blank-project rate whose starting date is after the requested date
        Rate.DeleteAll();
        InsertRate('EQ05', '', 20260601D, 200, 0);
        // [WHEN] the unit cost is resolved on an earlier date
        // [THEN] the future-dated rate does not apply and zero is returned
        Assert.AreEqual(0, Rate.FindUnitCost('EQ05', '', 20260101D), 'rate starting after the date is ignored');
    end;

    [Test]
    procedure FindHireRate_ProjectRate_PreferredOverBlankProject()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] a blank-project hire rate and a project-specific hire rate
        Rate.DeleteAll();
        InsertRate('EQ06', '', 20260101D, 0, 300);
        InsertRate('EQ06', 'PROJ-D', 20260101D, 0, 450);
        // [WHEN] the hire rate is resolved for that project
        // [THEN] the project-specific hire rate wins
        Assert.AreEqual(450, Rate.FindHireRate('EQ06', 'PROJ-D', 20260601D), 'project hire rate preferred');
    end;

    [Test]
    procedure FindHireRate_NoRate_ReturnsZero()
    var
        Rate: Record "CONS Equipment Rate";
    begin
        // [GIVEN] no hire rates for the equipment
        Rate.DeleteAll();
        // [WHEN] the hire rate is resolved
        // [THEN] zero is returned
        Assert.AreEqual(0, Rate.FindHireRate('EQ07', '', 20260601D), 'no hire rate returns 0');
    end;

    [Test]
    procedure MeterOnInsert_UpdatesEquipmentMeterReading()
    var
        Equipment: Record "CONS Equipment";
        MeterEntry: Record "CONS Equipment Meter Entry";
        Logic: Codeunit "CONS Equipment Meter Logic";
    begin
        // [GIVEN] an equipment record with an old meter reading and a new meter entry
        Equipment.DeleteAll();
        Equipment."No." := 'METER01';
        Equipment."Meter Reading" := 1000;
        Equipment.Insert();
        MeterEntry."Equipment No." := 'METER01';
        MeterEntry."Meter Reading" := 1250;
        // [WHEN] the meter entry insert logic runs
        Logic.Trigger_OnInsert(MeterEntry);
        // [THEN] the equipment's meter reading is updated to the new reading
        Equipment.Get('METER01');
        Assert.AreEqual(1250, Equipment."Meter Reading", 'equipment meter reading updated from entry');
    end;

    [Test]
    procedure MeterOnInsert_BlankEquipment_DoesNothing()
    var
        MeterEntry: Record "CONS Equipment Meter Entry";
        Logic: Codeunit "CONS Equipment Meter Logic";
    begin
        // [GIVEN] a meter entry with no equipment no.
        MeterEntry."Equipment No." := '';
        MeterEntry."Meter Reading" := 500;
        // [WHEN]/[THEN] the insert logic exits without error
        Logic.Trigger_OnInsert(MeterEntry);
        Assert.IsTrue(true, 'blank equipment meter entry is ignored without error');
    end;

    [Test]
    procedure MaintOnInsert_UpdatesEquipmentServiceFields()
    var
        Equipment: Record "CONS Equipment";
        Maintenance: Record "CONS Equipment Maintenance";
        Logic: Codeunit "CONS Equipment Maint. Logic";
    begin
        // [GIVEN] an equipment record and a maintenance record with service dates and meter
        Equipment.DeleteAll();
        Equipment."No." := 'MAINT01';
        Equipment.Insert();
        Maintenance."Equipment No." := 'MAINT01';
        Maintenance."Maintenance Date" := 20260301D;
        Maintenance."Next Service Date" := 20260601D;
        Maintenance."Next Service Meter" := 5000;
        Maintenance."Meter Reading" := 4200;
        // [WHEN] the maintenance insert logic runs
        Logic.Trigger_OnInsert(Maintenance);
        // [THEN] the equipment's last/next service and meter fields are updated
        Equipment.Get('MAINT01');
        Assert.IsTrue(Equipment."Last Service Date" = 20260301D, 'last service date set from maintenance date');
        Assert.IsTrue(Equipment."Next Service Date" = 20260601D, 'next service date copied from maintenance');
        Assert.AreEqual(5000, Equipment."Next Service Meter", 'next service meter copied from maintenance');
        Assert.AreEqual(4200, Equipment."Meter Reading", 'meter reading copied from maintenance');
    end;

    [Test]
    procedure MaintOnInsert_ZeroOptionalFields_LeaveEquipmentUnchanged()
    var
        Equipment: Record "CONS Equipment";
        Maintenance: Record "CONS Equipment Maintenance";
        Logic: Codeunit "CONS Equipment Maint. Logic";
    begin
        // [GIVEN] an equipment with existing next-service values and a maintenance with only a date
        Equipment.DeleteAll();
        Equipment."No." := 'MAINT02';
        Equipment."Next Service Date" := 20260901D;
        Equipment."Next Service Meter" := 8000;
        Equipment."Meter Reading" := 7000;
        Equipment.Insert();
        Maintenance."Equipment No." := 'MAINT02';
        Maintenance."Maintenance Date" := 20260401D;
        // [WHEN] the maintenance insert logic runs with zero optional fields
        Logic.Trigger_OnInsert(Maintenance);
        // [THEN] only the last service date changes; existing next-service values are preserved
        Equipment.Get('MAINT02');
        Assert.IsTrue(Equipment."Last Service Date" = 20260401D, 'last service date set from maintenance date');
        Assert.IsTrue(Equipment."Next Service Date" = 20260901D, 'next service date preserved when maintenance value is zero');
        Assert.AreEqual(8000, Equipment."Next Service Meter", 'next service meter preserved when maintenance value is zero');
        Assert.AreEqual(7000, Equipment."Meter Reading", 'meter reading preserved when maintenance value is zero');
    end;

    local procedure InsertRate(EquipmentNo: Code[20]; ProjectNo: Code[20]; StartingDate: Date; UnitCost: Decimal; HireRate: Decimal)
    var
        Rate: Record "CONS Equipment Rate";
    begin
        Rate.Init();
        Rate."Equipment No." := EquipmentNo;
        Rate."Project No." := ProjectNo;
        Rate."Starting Date" := StartingDate;
        Rate."Unit Cost" := UnitCost;
        Rate."Hire Rate" := HireRate;
        Rate.Insert();
    end;
}
