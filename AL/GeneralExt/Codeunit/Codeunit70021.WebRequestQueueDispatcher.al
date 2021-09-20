codeunit 70021 "Web Request Queue Dispatcher"
{
    TableNo = "Web Request Queue";

    trigger OnRun()
    var
        WorkerSetup: Record "Web Request Worker Setup";
    begin
        WorkerSetup.Get(Rec."Worker Code");
        WorkerSetup.TestField(CodeunitId);
        Codeunit.Run(WorkerSetup.CodeunitId, Rec);
    end;

}
