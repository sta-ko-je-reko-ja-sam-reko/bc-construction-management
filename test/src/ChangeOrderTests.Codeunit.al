codeunit 50514 "CONS Change Order Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "CONS Assert";

    [Test]
    procedure Apply_BlankProjectNo_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        Logic: Codeunit "CONS Change Order Hdr Logic";
    begin
        // [GIVEN] a change order with no project assigned (in memory, no database write)
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := 'CO-T-001';
        ChangeOrderHeader."Project No." := '';
        // [WHEN] the change order is applied
        asserterror Logic.Apply(ChangeOrderHeader);
        // [THEN] the missing project guard (TestField "Project No.") fires before any database access
        Assert.ExpectedError('Project No.');
    end;

    [Test]
    procedure Apply_AlreadyApproved_Errors()
    var
        ChangeOrderHeader: Record "CONS Change Order Header";
        Logic: Codeunit "CONS Change Order Hdr Logic";
    begin
        // [GIVEN] a change order that has already been applied (Status = Approved), project set
        ChangeOrderHeader.Init();
        ChangeOrderHeader."No." := 'CO-T-002';
        ChangeOrderHeader."Project No." := 'PROJ-T';
        ChangeOrderHeader.Status := ChangeOrderHeader.Status::Approved;
        // [WHEN] the change order is applied a second time
        asserterror Logic.Apply(ChangeOrderHeader);
        // [THEN] the already-applied guard fires before any contract/budget posting
        Assert.ExpectedError('already been applied');
    end;
}
