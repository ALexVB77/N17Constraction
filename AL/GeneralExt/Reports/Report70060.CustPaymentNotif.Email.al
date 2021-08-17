report 70060 "Cust. Payment Notif. Email"
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
            begin
                AgrDateFull := Format(Agr."Agreement Date", 0, '<Day> <Month Text> <Year4> года');
                PaymentAmountText := Format(PaymentAmount);
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
        Recipients: List of [Text];

        Log: Record "Cust. E-Mail Notify Log";

    begin
        if (not Cust.Get(CustAgr."Customer No.")) or (Cust."E-Mail" = '') then
            exit;

        TempBlob.CreateOutStream(OutS);
        RecRef.Open(Database::"Customer Agreement");
        FldRef := RecRef.Field(1);
        FldRef.SetRange(CustAgr."Customer No.");
        FldRef := RecRef.Field(2);
        FldRef.SetRange(CustAgr."No.");
        self.SetParam(PaymentAmount);
        self.SaveAs('', ReportFormat::Html, OutS, RecRef);
        TempBlob.CreateInStream(InS);
        InS.ReadText(MailBody);

        Recipients.Add(Cust."E-Mail");
        //to-do: send mail via ?

        Log.Init();
        Log."Agreement No." := CustAgr."No.";
        Log."Customer No." := CustAgr."Customer No.";
        Log.Body.CreateOutStream(OutS);
        Log."E-Mail" := Cust."E-Mail";
        CopyStream(OutS, InS);
        Log.Insert(true);

    end;

    procedure SendMailDBG(var CustAgr: Record "Customer Agreement"; PaymentAmount: Decimal)
    var
        Cust: Record Customer;
        self: Report "Cust. Payment Notif. Email";
        OutS: OutStream;
        InS: InStream;
        RecRef: RecordRef;
        FldRef: FieldRef;
        TEmpBlob: Codeunit "Temp Blob";
        MailBody: Text;
        Recipients: List of [Text];
        Mail: Codeunit Email;
        MailMsg: Codeunit "Email Message";

        Log: Record "Cust. E-Mail Notify Log";


    begin
        Cust."E-Mail" := 'rkharitonov@navicons.ru';
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
            Log.Body.CreateOutStream(OutS);
            Log."E-Mail" := Cust."E-Mail";
            CopyStream(OutS, InS);
            Log.Insert(true);
        end;
    end;


}
