codeunit 50200 "Local Report Management Ext"
{
    trigger OnRun()
    begin

    end;

    var
        LocRepMgt: Codeunit "Local Report Management";

        Currency: Record Currency;
        Employee: Record Employee;
        CompanyInfo: Record "Company Information";
        DocumentSignature: Record "Document Signature";
        PostedDocumentSignature: Record "Posted Document Signature";
        SalesPost: Codeunit "Sales-Post";
        RoundingAmount: Decimal;

        AccountDecimalPoint: Integer;
        CurrentDecPointQuantity: Integer;
        CurrentDecPointPrice: Integer;
        CurrentDecPointPriceLCY: Integer;
        CurrentDecPointDiscount: Integer;
        ShowCurrency: Boolean;
        PricesInclVAT: Boolean;
        DecimalFractionSerarator: Text[1];
        SalesHeaderTypeOffset: Integer;
        RepDate: Date;

    procedure GetDirectorName2(PostedDocument: Boolean; TableID: Integer; DocumentType: Integer; DocumentNo: Code[20]; ExpDate: Date): Text[250]
    var

        EmployeePosition: Text[250];
        EmployeeName: Text[250];
        EmployeeSignAuthorityDoc: Text[100];
        lrEmployee: Record Employee;
    begin

        IF LocRepMgt.GetDocSignEmplInfo(
             PostedDocument,
             TableID,
             DocumentType,
             DocumentNo,
             DocumentSignature."Employee Type"::Director,
             EmployeePosition,
             EmployeeName,
             EmployeeSignAuthorityDoc)
        THEN
            EXIT(EmployeePosition + '  \' + EmployeeName);

        CompanyInfo.RESET;
        CompanyInfo.SETFILTER("Expired Date", '%1..', ExpDate);
        IF NOT CompanyInfo.FINDFIRST THEN BEGIN
            CompanyInfo.SETRANGE("Expired Date");
            IF NOT CompanyInfo.FINDLAST THEN
                CompanyInfo.INIT;
        END;

        IF lrEmployee.GET(CompanyInfo."Director No.") THEN;



        IF CompanyInfo."Director Name 2" <> '' THEN
            EXIT(lrEmployee."Job Title" + '  \' + CompanyInfo."Director Name" + ' ' + CompanyInfo."Director Name 2")
        ELSE
            EXIT(lrEmployee."Job Title" + '  \' + CompanyInfo."Director Name");
    end;
}