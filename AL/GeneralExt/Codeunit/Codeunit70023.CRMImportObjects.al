codeunit 70023 "CRM Import Objects"
{
    trigger OnRun()
    begin
        Code
    end;

    var
        CrmWorker: Codeunit "CRM Worker";

    local procedure Code()
    var
        FetchedObject: Record "CRM Prefetched Object";
    begin
        FetchedObject.Reset();
        FetchedObject.Setrange("Company name", CompanyName());
        CrmWorker.ImportObjects(FetchedObject);
    end;
}
