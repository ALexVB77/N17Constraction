codeunit 99930 "CRM Integration API"
{
    trigger OnRun()
    begin

    end;

    procedure ImportObject(crmObjects: Text): Text
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Wrq: Record "Web Request Queue";
        WrqDispatcher: Codeunit "Web Request Queue Dispatcher";
    begin
        SalesSetup.Get();
        CreateQueueTask(Wrq, SalesSetup."CRM Worker Code", crmObjects);
        Commit();
        if not IsNullGuid(Wrq.Id) then begin
            ClearLastError();
            if not WrqDispatcher.Run(Wrq) then
                Error(GetLastErrorText());
        end;
        exit('OK');
    end;

    procedure GetApartmentType(cmrObjectXml: Text) response: Text
    var
        CrmWorker: Codeunit "CRM Worker";
    begin
        response := CrmWorker.GetApartmentType(cmrObjectXml);
    end;

    local procedure CreateQueueTask(var NewWrq: record "Web Request Queue"; WorkerCode: Code[20]; RequestBodyText: Text)
    var
        OutStream: OutStream;
    begin
        NewWrq.Init();
        NewWrq.Id := CreateGuid();
        NewWrq.Validate("Worker Code", WorkerCode);
        NewWrq."Request Body".CreateOutStream(OutStream);
        OutStream.Write(RequestBodyText);
        NewWrq."Datetime creating" := CurrentDateTime;
        NewWrq.Status := NewWrq.Status::New;
        NewWrq.Insert(True);
    end;

}
