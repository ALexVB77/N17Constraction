report 50040 "Cover Sheet"
{
    Caption = 'Cover Sheet';
    DefaultLayout = Word;
    //EnableHyperlinks = true;
    PreviewMode = PrintLayout;
    WordLayout = './Reports/Layouts/CoverSheet.docx';
    WordMergeDataItem = Header;

    dataset
    {
        dataitem(Header; "Purchase Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                WHERE("Document Type" = const(Order), "Act Type" = filter(Act | "KC-2" | Advance));
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Purchase Order Act';
            column(Title; Title)
            { }
            column(ErrStatus; ErrStatus)
            { }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.")
            { }
            column(VendorName; VendorName)
            { }
            column(Agreement_No_; "Agreement No.")
            { }
            column(External_Agreement_No_; "External Agreement No.")
            { }
            column(No_; "No.")
            { }
            column(Vendor_Invoice_No_; "Vendor Invoice No.")
            { }
            column(Document_Date; DocDateText)
            { }
            column(Invoice_Amount_Incl__VAT; "Invoice Amount Incl. VAT")
            { }
            column(Invoice_VAT_Amount; "Invoice VAT Amount")
            { }
            column(InvoiceAmount; "Invoice Amount Incl. VAT" - "Invoice VAT Amount")
            { }
            column(BarcodePrint; BarcodePrint)
            { }
            column(CompName; CompanyName)
            { }

            dataitem(Line; "Purchase Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(Full_Description; "Full Description")
                { }
                column(Quantity; Quantity)
                { }
                column(UOM_Code; "Unit of Measure Code")
                { }
                column(Curr_Code; "Currency Code")
                { }
                column(Unit_Cost; "Direct Unit Cost")
                { }
                column(Line_Amount; "Line Amount")
                { }
                column(Amt_Inc_VAT; AmountInclVAT)
                { }
                column(CPCode; CPDimValueCode)
                { }
                column(CCCode; CCDimValueCode)
                { }
                column(UtilCode; UtilitiesDimValueCode)
                { }

                trigger OnAfterGetRecord()
                var
                    TempPurchLine: Record "Purchase Line" temporary;
                    TempVATAmountLine: Record "VAT Amount Line" temporary;
                begin
                    if "Dimension Set ID" <> 0 then begin
                        CPDimValueCode := '';
                        CCDimValueCode := '';
                        UtilitiesDimValueCode := '';
                        if PurchSetup."Cost Place Dimension" <> '' then
                            if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Place Dimension") then
                                CPDimValueCode := DimSetEntry."Dimension Value Code";
                        if PurchSetup."Cost Code Dimension" <> '' then
                            if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Code Dimension") then
                                CCDimValueCode := DimSetEntry."Dimension Value Code";
                        if GLSetup."Utilities Dimension Code" <> '' then
                            if DimSetEntry.Get("Dimension Set ID", GLSetup."Utilities Dimension Code") then
                                UtilitiesDimValueCode := DimSetEntry."Dimension Value Code";
                    end;
                    TempPurchLine.Reset;
                    TempPurchLine.DeleteAll();
                    TempPurchLine := Line;
                    TempPurchLine.Insert;
                    TempPurchLine.CalcVATAmountLines(0, Header, TempPurchLine, TempVATAmountLine);
                    TempPurchLine.UpdateVATOnLines(0, Header, TempPurchLine, TempVATAmountLine);
                    AmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();
                end;
            }

            dataitem(Approval; "Approval Entry")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Table ID", "Document Type", "Document No.", "Date-Time Sent for Approval")
                                    where("Table ID" = const(38)/*, Status = const(Approved)*/);
                column(UserActType; UserActType)
                { }
                column(Approver_ID; "Approver ID")
                { }
                column(Status; Status)
                { }
                column(Date_Time_Sent; "Date-Time Sent for Approval")
                { }
                column(Date_Time_Appr; "Last Date-Time Modified")
                { }

                trigger OnAfterGetRecord()
                var
                    MessageResponsNo: Integer;
                    ResponsText: label 'Reception,Controller,Estimator,Checker,Pre. Approver,Approver,Signer,Accountant';
                begin
                    MessageResponsNo :=
                        PaymentOrderMgt.GetMessageResponsNo(
                            Approval."IW Documents", Approval."Status App Act".AsInteger(), Approval."Preliminary Approval");
                    UserActType := SelectStr(MessageResponsNo, ResponsText);
                end;
            }

            trigger OnAfterGetRecord()
            var
                Barcode: Codeunit Barcode;
                BarcodeNumber: Text;
            begin
                if "Act Type" = "Act Type"::Act THEN
                    Title := Text001
                ELSE
                    Title := Text002;
                if Vendor.Get("Buy-from Vendor No.") then begin
                    if Vendor."Full Name" <> '' then
                        VendorName := Vendor."Full Name"
                    else
                        VendorName := Vendor.Name + Vendor."Name 2";
                end;
                IF "Problem Type" = "Problem Type"::"Act error" THEN
                    ErrStatus := ProblemDocText;
                DocDateText := Format("Document Date");

                BarcodeNumber := Barcode.CreateBarcode(COPYSTR("No.", 4, 6));
                //BarcodePrint := Barcode.Ean13(BarcodeNumber);
                CreateBarcode();
            end;
        }
    }

    trigger OnPreReport()
    begin
        PurchSetup.Get();
        GLSetup.Get();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        DimSetEntry: Record "Dimension Set Entry";
        Vendor: Record Vendor;
        PaymentOrderMgt: Codeunit "Payment Order Management";
        Title, ErrStatus, VendorName : text;
        AmountInclVAT: Decimal;
        CPDimValueCode, CCDimValueCode, UtilitiesDimValueCode : code[20];
        BarcodePrint, CompName : text;
        UserActType, DocDateText : text;
        Text001: Label 'Сопроводительный лист к акту.';
        Text002: Label 'Сопроводительный лист к КС-2.';
        ProblemDocText: Label 'Этот акт имеет статус проблемный!';

    local procedure CreateBarcode()
    var
    //EncodingOption: DotNet 
    begin

    end;

}