namespace Construction.Equipment;

table 50414 "CONS Equipment Meter Entry"
{
    Caption = 'Equipment Meter Entry';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the unique entry number of the meter reading.';
        }
        field(5; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            DataClassification = CustomerContent;
            TableRelation = "CONS Equipment";
            ToolTip = 'Specifies the equipment the meter reading relates to.';
        }
        field(10; "Reading Date"; Date)
        {
            Caption = 'Reading Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the meter reading was taken.';
        }
        field(15; "Meter Reading"; Decimal)
        {
            Caption = 'Meter Reading';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the recorded meter reading of the equipment.';
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the meter reading.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Equipment; "Equipment No.")
        {
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    var
        ILogic: Interface "CONS IEquipmentMeter";
        ILogicDefined: Boolean;

    local procedure Logic(): Interface "CONS IEquipmentMeter"
    var
        Default: Codeunit "CONS Equipment Meter Logic";
    begin
        if not ILogicDefined then
            Define(Default);
        exit(ILogic);
    end;

    /// <summary>Injects an alternative meter-logic implementation (tests / downstream overrides).</summary>
    /// <param name="Implementation">The logic implementation to use.</param>
    procedure Define(Implementation: Interface "CONS IEquipmentMeter")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;
}
