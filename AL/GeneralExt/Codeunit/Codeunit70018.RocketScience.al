codeunit 70018 "Rocket Science"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    [TryFunction]
    procedure InsertTry()
    var
        EntryNo: Integer;
        rr: Record "Test rec";
    begin
        if rr.FindLast() then
            EntryNo := rr."Entry No." + 1
        else
            EntryNo := 1;

        rr.Init();
        rr."Entry No." := EntryNo;
        rr.Name := StrSubstNo('Record %1', EntryNo);
        rr.Insert();
    end;

    [TryFunction]
    procedure ModifyTry()
    var
        EntryNo: Integer;
        rr: Record "Test rec";
    begin
        if not rr.FindLast() then
            exit;
        rr.Name := Format(CurrentDateTime());
        rr.Modify()
    end;
}
