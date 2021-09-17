report 70015 "Cust. Payment Notif. Email"
/*  Отчет используется только для генерации html тела письма уведомления о получении оплаты
    Для других видов отчетов, которые были в репорте 70060, создавайте новый объект
*/
{
    Caption = 'Customer Payment Notification Email';
    UsageCategory = Administration;
    ApplicationArea = All;
    UseRequestPage = false;
    DefaultLayout = Word;
    WordLayout = './Reports/Layouts/CustPaymentNotificationEmail.docx';

    dataset
    {
        dataitem(Agr; "Customer Agreement")
        {
            DataItemTableView = SORTING("Customer No.", "No.") ORDER(Ascending);

            column(ExternalAgrNo; Agr."External Agreement No.")
            {

            }

            column(AgrDateFull; AgrDateFull)
            {

            }

            column(FirstName; Cont."First Name")
            {

            }

            column(MiddleName; Cont."Middle Name")
            {

            }

            column(PaymentAmountText; PaymentAmountText)
            {

            }

            trigger OnAfterGetRecord()
            var
                Cust: Record Customer;
                ContBusRel: Record "Contact Business Relation";
                LocMgt: Codeunit "Localisation Management";
            begin
                AgrDateFull := FmtDate(Agr."Agreement Date");
                PaymentAmountText := LowerCase(LocMgt.Amount2Text('', PaymentAmount));
                Clear(Cont);
                if Cust.Get(Agr."Customer No.") then begin
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.SetRange("No.", Cust."No.");
                    if ContBusRel.FindFirst() then begin
                        if Cont.Get(ContBusRel."Contact No.") then;
                    end;
                end;

            end;

        }
    }

    var
        AgrDateFull, FirstName, MiddleName, PaymentAmountText : Text;
        Cont: Record Contact;
        PaymentAmount: Decimal;

    procedure SetParam(PaymentAmountP: Decimal)
    begin
        PaymentAmount := PaymentAmountP;

    end;

    procedure SendMail(var CustAgr: Record "Customer Agreement"; PaymentAmount: Decimal)
    var
        Cust: Record Customer;
        self: Report "Cust. Payment Notif. Email";
        OutS: OutStream;
        InS: InStream;
        RecRef: RecordRef;
        FldRef: FieldRef;
        TEmpBlob: Codeunit "Temp Blob";
        MailBody: Text;
        Mail: Codeunit Email;
        MailMsg: Codeunit "Email Message";
        Log: Record "Cust. E-Mail Notify Log";
    begin
        if (not Cust.Get(CustAgr."Customer No.")) or (Cust."E-Mail" = '') then
            exit;
        TempBlob.CreateOutStream(OutS, TextEncoding::UTF8);
        RecRef.Open(Database::"Customer Agreement");
        FldRef := RecRef.Field(1);
        FldRef.SetRange(CustAgr."Customer No.");
        FldRef := RecRef.Field(2);
        FldRef.SetRange(CustAgr."No.");
        self.SetParam(PaymentAmount);
        self.SaveAs('', ReportFormat::Html, OutS, RecRef);
        TempBlob.CreateInStream(InS, TextEncoding::UTF8);
        InS.ReadText(MailBody);
        MailMsg.Create(Cust."E-Mail", CompanyName(), MailBody, true);
        if Mail.Send(MailMsg, Enum::"Email Scenario"::Default) then begin
            Log.Init();
            Log."Agreement No." := CustAgr."No.";
            Log."Customer No." := CustAgr."Customer No.";
            Log.Body.CreateOutStream(OutS, TextEncoding::UTF8);
            OutS.WriteText(MailBody);
            Log."E-Mail" := Cust."E-Mail";
            Log.Insert(true);
        end;
    end;

    local procedure FmtDate(DateToFormat: Date) Result: Text
    var
        MonthRus: Option " ",января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря;
        D, M, Y : Text;
    begin
        D := Format(Date2DMY(DateToFormat, 1));
        if StrLen(D) = 1 then
            D := '0' + D;
        MonthRus := Date2DMY(DateToFormat, 2);
        Y := Format(Date2DMY(DateToFormat, 3));
        Result := StrSubstNo('%1 %2 %3 года', D, MonthRus, Y);
    end;


}
