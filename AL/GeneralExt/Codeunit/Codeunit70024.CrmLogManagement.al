codeunit 70024 "Crm Log Management"
{
    TableNo = "CRM Log";

    trigger OnRun()
    var
        CrmLog: Record "CRM Log";
        LastEntryNo: BigInteger;
    begin
        if Rec."Entry No." = 0L then begin
            if CrmLog.FindLast() then
                LastEntryNo := CrmLog."Entry No." + 1
            else
                LastEntryNo := 1;
            CrmLog := Rec;
            CrmLog."Entry No." := LastEntryNo;
            CrmLog.Insert(true);
        end;
    end;
}
