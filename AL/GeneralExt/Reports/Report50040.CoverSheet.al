report 50040 "Cover Sheet"
{
    WordLayout = './Reports/Layouts/CoverSheet.docx';
    Caption = 'Cover Sheet';
    DefaultLayout = Word;
    EnableHyperlinks = true;
    PreviewMode = PrintLayout;
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
            column(VendorName; Vendor."Full Name")
            { }
            column(Agreement_No_; "Agreement No.")
            { }
            column(External_Agreement_No_; "External Agreement No.")
            { }
            column(No_; "No.")
            { }
            column(Vendor_Invoice_No_; "Vendor Invoice No.")
            { }
            column(Document_Date; "Document Date")
            { }
            column(Invoice_Amount_Incl__VAT; "Invoice Amount Incl. VAT")
            { }
            column(Invoice_VAT_Amount; "Invoice VAT Amount")
            { }
            column(InvoiceAmount; "Invoice Amount Incl. VAT" - "Invoice VAT Amount")
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
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                { }
                column(Currency_Code; "Currency Code")
                { }
                column(Direct_Unit_Cost; "Direct Unit Cost")
                { }
                column(Line_Amount; "Line Amount")
                { }
                column(Amount_Including_VAT; AmountInclVAT)
                { }
                column(CostPlaceCode; CPDimValueCode)
                { }
                column(CostCodeCode; CCDimValueCode)
                { }
                column(UtilitiesCode; UtilitiesDimValueCode)
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
                DataItemTableView = sorting("Table ID", "Document Type", "Document No.", "Sequence No.", "Record ID to Approve")
                                    where("Table ID" = const(38)/*, Status = const(Approved)*/);
                column(UserActType; UserActType)
                { }
                column(Approver_ID; "Approver ID")
                { }
                column(Status; Status)
                { }
                column(Date_Time_Sent_for_Approval; "Date-Time Sent for Approval")
                { }
                column(Last_Date_Time_Modified; "Last Date-Time Modified")
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
        Title, ErrStatus : text;
        AmountInclVAT: Decimal;
        CPDimValueCode, CCDimValueCode, UtilitiesDimValueCode : code[20];
        UserActType: text;
}