report 70043 "Payment Request"
{
    Caption = 'Payment Request';
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    WordLayout = './Reports/Layouts/PaymentRequest.docx';
    WordMergeDataItem = Header;

    dataset
    {
        dataitem(Header; "Purchase Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                            WHERE("Document Type" = const(Order), "IW Documents" = const(true));
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Purchase Order App';
            column(Title; Title)
            { }
            column(ReportDT; ReportDT)
            { }
            column(ReceivedDate; Format("Document Date"))
            { }
            column(DueDate; Format("Due Date"))
            { }
            column(CHDate; Format(CHDate))
            { }
            column(CHUser; CHUser)
            { }
            column(ApprDate; Format(ApprDate))
            { }
            column(ApprUser; ApprUser)
            { }
            column(Supplier; "Buy-from Vendor Name")
            { }
            column(Contract; "External Agreement No. (Calc)")
            { }
            column(InvoiceNo; "Vendor Invoice No.")
            { }
            column(Invoice_Amount_Incl__VAT; "Invoice Amount Incl. VAT")
            { }
            column(Invoice_VAT_Amount; "Invoice VAT Amount")
            { }
            column(VendorBankAcc; "Vendor Bank Account No.")
            { }
            column(VendorBankName; VendorBankName)
            { }
            column(VendorBankBIC; "Vendor Bank Account")
            { }
            column(PaymentDetails; "Payment Details")
            { }
            column(OKATOCode; "OKATO Code")
            { }
            column(KBKCode; "KBK Code")
            { }

            dataitem(Line; "Purchase Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                column(CPCode; CPDimValueCode)
                { }
                column(CCCode; CCDimValueCode)
                { }
                column(Full_Description; "Full Description")
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_Cost; "Direct Unit Cost")
                { }
                column(Line_Amount; "Line Amount")
                { }

                trigger OnAfterGetRecord()
                var
                    TempPurchLine: Record "Purchase Line" temporary;
                    TempVATAmountLine: Record "VAT Amount Line" temporary;
                begin
                    if "Dimension Set ID" <> 0 then begin
                        CPDimValueCode := '';
                        CCDimValueCode := '';
                        if PurchSetup."Cost Place Dimension" <> '' then
                            if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Place Dimension") then
                                CPDimValueCode := DimSetEntry."Dimension Value Code";
                        if PurchSetup."Cost Code Dimension" <> '' then
                            if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Code Dimension") then
                                CCDimValueCode := DimSetEntry."Dimension Value Code";
                    end;
                end;

            }

            trigger OnAfterGetRecord()
            begin
                Title := StrSubstNo('%1 %2', CompanyInfo.Name, "No.");
                GetAppoveInfo(CHDate, CHUser, ApprDate, ApprUser);
                VendorBankName := GetVendorBankAccountName("Pay-to Vendor No.", "Vendor Bank Account No.");
            end;

        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        PurchSetup.Get();
        ReportDT := Format(CurrentDateTime());
    end;

    var
        CompanyInfo: Record "Company Information";
        PurchSetup: Record "Purchases & Payables Setup";
        DimSetEntry: Record "Dimension Set Entry";
        Title, ReportDT, VendorBankName : text;
        CHDate, ApprDate : date;
        CHUser, ApprUser : Code[50];
        CPDimValueCode, CCDimValueCode : code[20];

    local procedure GetVendorBankAccountName(VendCode: Code[20]; VendorBankNo: Code[20]): text
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if VendorBankNo <> '' then
            if VendorBankAccount.get(VendCode, VendorBankNo) then
                exit(VendorBankAccount.Name + VendorBankAccount."Name 2");
    end;

}