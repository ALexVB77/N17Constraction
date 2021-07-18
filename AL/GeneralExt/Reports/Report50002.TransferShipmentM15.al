report 50002 "Transfer Shipment M-15"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem(TransferHeader; "Transfer Shipment Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";

            dataitem(CopyCycle; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(LineCycle; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));

                    trigger OnPreDataItem()
                    begin
                        Currency.InitRoundingPrecision;
                        VATExemptTotal := true;
                        i := 0;
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not SalesLine1.FindSet() then
                                CurrReport.Break();
                        end else
                            if SalesLine1.Next(1) = 0 then
                                CurrReport.Break();

                        CopyArray(LastTotalAmount, TotalAmount, 1);

                        InvPostingSetup.Reset();
                        InvPostingSetup.SetRange("Location Code", SalesLine1."Location Code");
                        InvPostingSetup.SetRange("Invt. Posting Group Code", SalesLine1."Posting Group");

                        if InvPostingSetup.FindSet() then
                            BalAccNo := InvPostingSetup."Inventory Account"
                        else
                            BalAccNo := '';

                        i += 1;

                        if not UnitOfMeasure.Get(SalesLine1."Unit of Measure Code") then
                            Clear(UnitOfMeasure);

                        ItemDescription := SalesLine1.Description + SalesLine1."Description 2";

                        Clear(UnitCostTxt);
                        Clear(AmountTxt);
                        Clear(VATAmountTxt);
                        Clear(IncVATAmountTxt);

                        Amount := SalesLine1."Amount (LCY)";

                        if Item.Get(SalesLine1."No.") and Vendor.Get(TransferHeader."Vendor No.") then
                            if VATPostingSetup.Get(Vendor."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                                VAT := Round(Amount * VATPostingSetup."VAT %" / 100);

                        AmountIncVAT := Amount + VAT;
                        VATAmount += VAT;
                        TotalAmount1 += AmountIncVAT;
                        if SalesLine1."Qty. to Invoice" <> 0 then
                            UnitCostTxt := Format(Amount / SalesLine1."Qty. to Invoice", 0, '<Precision,2:2><Standard Format,0>');
                        AmountTxt := Format(Amount, 0, '<Precision,2:2><Standard Format,0>');
                        VATAmountTxt := Format(VAT, 0, '<Precision,2:2><Standard Format,0>');
                        IncVATAmountTxt := Format(AmountIncVAT, 0, '<Precision,2:2><Standard Format,0>');

                        if not PrintPrice then begin
                            UnitCostTxt := '-';
                            AmountTxt := '-';
                        end;

                        Qty1Txt := Format(SalesLine1."Qty. to Invoice");
                        Qty2Txt := Format(SalesLine1."Qty. to Invoice");

                        txtItemNo := SalesLine1."No.";
                        if SalesLine1."Variant Code" <> '' then
                            txtItemNo := txtItemNo + '(' + SalesLine1."Variant Code" + ')';

                        FillBody(SalesLine1."Shortcut Dimension 1 Code", SalesLine1."Shortcut Dimension 2 Code", SalesLine1."Unit of Measure Code");
                    end;

                    trigger OnPostDataItem()
                    begin
                        TotalAmountTxt := LocMgt.Amount2Text('', TotalAmount1);
                        TotalVATAmountTxt := LocMgt.Amount2Text('', VATAmount);
                        if not PrintPrice then begin
                            TotalAmountTxt := '-';
                            TotalVATAmountTxt := '-';
                        end;

                        FillFooter();
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, CopiesNumber);
                end;

                trigger OnAfterGetRecord()
                begin
                    Clear(TotalAmount);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInfo.Get;

                LineCount := SalesLine1.Count;

                CheckSignature(PassedBy, PassedBy."Employee Type"::PassedBy);
                CheckSignature(ApprovedBy, PassedBy."Employee Type"::Responsible);
                CheckSignature(ReleasedBy, ReleasedBy."Employee Type"::ReleasedBy);
                CheckSignature(ReceivedBy, ReceivedBy."Employee Type"::ReceivedBy);
                CheckSignature(RequestedBy, ReceivedBy."Employee Type"::RequestedBy);

                TransferShipmentLine.Reset();
                ;
                TransferShipmentLine.SetRange("Document No.", "No.");

                if TransferShipmentLine.FindFirst() then
                    repeat
                        SalesLine1.Init();
                        SalesLine1."Document Type" := SalesLine1."Document Type"::Order;
                        SalesLine1."Document No." := TransferShipmentLine."Document No.";
                        SalesLine1."Line No." := TransferShipmentLine."Line No.";
                        SalesLine1.Type := SalesLine1.Type::Item;
                        SalesLine1."No." := TransferShipmentLine."Item No.";
                        SalesLine1."Location Code" := TransferShipmentLine."Transfer-from Code";
                        SalesLine1.Description := TransferShipmentLine.Description;
                        SalesLine1."Description 2" := TransferShipmentLine."Description 2";
                        SalesLine1."Unit of Measure" := TransferShipmentLine."Unit of Measure";
                        SalesLine1."Unit of Measure Code" := TransferShipmentLine."Unit of Measure Code";
                        SalesLine1."Qty. per Unit of Measure" := TransferShipmentLine."Qty. per Unit of Measure";
                        SalesLine1."Qty. to Invoice" := TransferShipmentLine.Quantity;
                        SalesLine1."Qty. to Invoice (Base)" := TransferShipmentLine."Quantity (Base)";
                        SalesLine1."Posting Group" := TransferShipmentLine."Inventory Posting Group";
                        SalesLine1."Variant Code" := TransferShipmentLine."Variant Code";
                        SalesLine1."Shortcut Dimension 1 Code" := TransferShipmentLine."Shortcut Dimension 1 Code";
                        SalesLine1."Shortcut Dimension 2 Code" := TransferShipmentLine."Shortcut Dimension 2 Code";

                        ItemLedgerEntry.Get(TransferShipmentLine."Item Shpt. Entry No.");
                        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                        SalesLine1."Amount (LCY)" := Abs(ItemLedgerEntry."Cost Amount (Actual)");
                        SalesLine1."Amount Including VAT (LCY)" := Abs(ItemLedgerEntry."Cost Amount (Actual)");
                        SalesLine1.Insert();
                    until TransferShipmentLine.Next() = 0;

                LineCount := SalesLine1.Count;

                Consignor := "Transfer-from Code";

                if Location.Get(Consignor) then
                    Consignor := Consignor + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                Consignee := "Transfer-to Code";
                if Location.Get(Consignee) then
                    Consignee := Consignee + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                if Vendor.Get("Vendor No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.GET("Vendor No.", "Agreement No.") then
                        ReasonName3 := StrSubstNo(Text12401, VendorAgreement."External Agreement No.");
                end;

                if Vendor.Get("Vendor No.") then
                    Consignee := Vendor."Full Name";

                FillHeader("Transfer Order No.", "Posting Date");
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;
                    field(PrintWithPrice; PrintPrice)
                    {
                        ApplicationArea = All;
                        Caption = 'Print With Price';
                    }
                }
                group(Responsible)
                {
                    Caption = 'Responsible';
                    field(AllowedEmployee; Employee2)
                    {
                        Caption = 'Allowed Employee';
                        ApplicationArea = All;
                        TableRelation = Employee;
                    }
                    field(ReleasedEmployee; Employee3)
                    {
                        Caption = 'Released Employee';
                        ApplicationArea = All;
                        TableRelation = Employee;
                    }
                    field(RecievedEmployee; Employee4)
                    {
                        Caption = 'Recieved Employee';
                        ApplicationArea = All;
                        TableRelation = Employee;
                    }
                }
                group(GroupName2)
                {
                    ShowCaption = false;
                    field(Reason; ReasonName3)
                    {
                        Caption = 'Reason';
                        ApplicationArea = All;
                    }
                    field(ExportToExcel; ExportToExcel)
                    {
                        Caption = 'Export to Excel';
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field(SaveInArchive; ArchiveDocument)
                    {
                        Caption = 'Save in Archive';
                        ApplicationArea = All;
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        ApplicationArea = All;
                    }
                    field(OperationType; OperationType)
                    {
                        Caption = 'Operation Type';
                        ApplicationArea = All;
                    }
                    field(NoOfCopies; CopiesNumber)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if CopiesNumber < 1 then
                                CopiesNumber := 1;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            PrintPrice := true;
            ExportToExcel := true;
        end;
    }

    var
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        CompanyInfo: Record "Company Information";
        LineCount: Integer;
        SalesLine1: Record "Sales Line" temporary;
        DocSignMgt: Codeunit "Doc. Signature Management";
        PassedBy: Record "Posted Document Signature";
        ApprovedBy: Record "Posted Document Signature";
        ReleasedBy: Record "Posted Document Signature";
        ReceivedBy: Record "Posted Document Signature";
        RequestedBy: Record "Posted Document Signature";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Consignor: Text;
        Location: Record Location;
        Consignee: Text;
        Vendor: Record Vendor;
        VendorAgreement: Record "Vendor Agreement";
        ReasonName3: Text;
        ExportToExcel: Boolean;
        LocRepMgt: Codeunit "Local Report Management";
        BalAccount: Code[20];
        UnitOfMeasure: Record "Unit of Measure";
        ItemDescription: Text;
        UnitCostTxt: Text;
        AmountTxt: Text;
        TotalAmount: array[8] of Decimal;
        Qty1Txt: Text;
        Qty2Txt: Text;
        txtItemNo: Code[20];
        TotalAmountTxt: Text;
        TotalVATAmountTxt: Text;
        LocalManagement: Codeunit "Localisation Management";
        VATAmount: Decimal;
        VATAmountTxt: Text;
        IncVATAmountTxt: Text;
        Employee2: Code[20];
        Employee3: Code[20];
        Employee4: Code[20];
        PrintPrice: Boolean;
        i: Integer;
        CopiesNumber: Integer;
        Currency: Record "Currency";
        VATExemptTotal: Boolean;
        LastTotalAmount: array[8] of Decimal;
        InvPostingSetup: Record "Inventory Posting Setup";
        BalAccNo: Code[20];
        Amount: Decimal;
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        VAT: Decimal;
        AmountIncVAT: Decimal;
        TotalAmount1: Decimal;
        LocMgt: Codeunit "Localisation Management";
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        OperationType: Text;
        Text12401: Label 'By agreement %1';

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        InitReportTemplate();
    end;

    trigger OnPostReport()
    var
        FileName: Text;
    begin
        if FileName = '' then
            ExcelReportBuilderManager.ExportData
        else
            ExcelReportBuilderManager.ExportDataToClientFile(FileName);
    end;

    local procedure InitReportTemplate()
    begin
        ExcelReportBuilderManager.InitTemplate('М-15-Н');
        ExcelReportBuilderManager.SetSheet('Sheet1');
    end;

    local procedure CheckSignature(var DocSign: Record "Posted Document Signature"; EmpType: Integer)
    var
        InvSetup: Record "Inventory Setup";
    begin
        DocSignMgt.GetPostedDocSign(DocSign, Database::"Transfer Shipment Header", 0, TransferHeader."No.", EmpType, true);
    end;

    local procedure GetCostCodeName(GlobalDimNo: Integer; GlobalDimCode: Code[20]): Text
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Global Dimension No.", 1);
        DimensionValue.SetRange(Code, GlobalDimCode);
        if DimensionValue.FindFirst() then
            exit(DimensionValue.Name);
        exit('');
    end;

    local procedure FillHeader(DocNo: Code[20]; PostingDate: Date)
    begin
        if ExportToExcel then begin
            if not ExcelReportBuilderManager.TryAddSection('REPORTHEADER') then begin
                ExcelReportBuilderManager.AddPagebreak;
                ExcelReportBuilderManager.AddSection('REPORTHEADER');
            end;
            ExcelReportBuilderManager.AddDataToSection('InvoiceID', Format(DocNo));
            ExcelReportBuilderManager.AddDataToSection('Organisation', Format(LocRepMgt.GetCompanyName()));
            ExcelReportBuilderManager.AddDataToSection('OKPO', Format(CompanyInfo."OKPO Code"));
            ExcelReportBuilderManager.AddDataToSection('InvoiceDate', Format(PostingDate));
            ExcelReportBuilderManager.AddDataToSection('Sender_StructDpt', Format(GetCostCodeName(1, TransferHeader."Shortcut Dimension 1 Code")));
            ExcelReportBuilderManager.AddDataToSection('Receiver_StructDpt', Format(GetCostCodeName(1, TransferHeader."New Shortcut Dimension 1 Code")));
            ExcelReportBuilderManager.AddDataToSection('InvoiceBasis', Format(ReasonName3));
            ExcelReportBuilderManager.AddDataToSection('Header_ToWhom', Format(Consignee));

            if not ExcelReportBuilderManager.TryAddSection('PAGEHEADER') then begin
                ExcelReportBuilderManager.AddPagebreak;
                ExcelReportBuilderManager.AddSection('PAGEHEADER');
            end;
        end;
    end;

    local procedure FillBody(ShortcutDimension1Code: Code[20]; ShortcutDimension2Code: Code[20]; UnitofMeasureCode: Code[20])
    begin
        if ExportToExcel then begin
            if not ExcelReportBuilderManager.TryAddSection('BODY') then begin
                ExcelReportBuilderManager.AddPagebreak;
                ExcelReportBuilderManager.AddSection('BODY');
            end;
            ExcelReportBuilderManager.AddDataToSection('AccountNum', Format(BalAccount));
            ExcelReportBuilderManager.AddDataToSection('ItemName', Format(ItemDescription));
            ExcelReportBuilderManager.AddDataToSection('ItemId', Format(txtItemNo));
            ExcelReportBuilderManager.AddDataToSection('CostPlace', Format(ShortcutDimension1Code));
            ExcelReportBuilderManager.AddDataToSection('CostCode', Format(ShortcutDimension2Code));
            ExcelReportBuilderManager.AddDataToSection('CodeOKEI', Format(UnitOfMeasure."OKEI Code"));
            ExcelReportBuilderManager.AddDataToSection('UnitId', Format(UnitofMeasureCode));
            ExcelReportBuilderManager.AddDataToSection('Qty', Format(Qty1Txt));
            ExcelReportBuilderManager.AddDataToSection('QtyIssue', Format(Qty2Txt));
            ExcelReportBuilderManager.AddDataToSection('Price', Format(UnitCostTxt));
            ExcelReportBuilderManager.AddDataToSection('LineAmount', Format(AmountTxt));

            if VATAmountTxt = '' then
                ExcelReportBuilderManager.AddDataToSection('VATAmount', '-')
            else
                ExcelReportBuilderManager.AddDataToSection('VATAmount', VATAmountTxt);

            if IncVATAmountTxt = '' then
                ExcelReportBuilderManager.AddDataToSection('LineAmountWithVAT', '-')
            else
                ExcelReportBuilderManager.AddDataToSection('LineAmountWithVAT', IncVATAmountTxt);
        END;
    end;

    local procedure FillFooter()
    begin
        if ExportToExcel then begin
            if not ExcelReportBuilderManager.TryAddSection('REPORTFOOTER') then begin
                ExcelReportBuilderManager.AddPagebreak;
                ExcelReportBuilderManager.AddSection('REPORTFOOTER');
            end;
            ExcelReportBuilderManager.AddDataToSection('F_TotalItemsShipped', Format(LocalManagement.Integer2Text(i, 2, 'наименование', 'наименования', 'наименований')));
            ExcelReportBuilderManager.AddDataToSection('F_TotalAmtWithVAT_Letters', TotalAmountTxt);
            ExcelReportBuilderManager.AddDataToSection('F_TotalVAT', TotalVATAmountTxt);
            ExcelReportBuilderManager.AddDataToSection('Director_Position', LocRepMgt.GetEmpPosition(Employee2));
            ExcelReportBuilderManager.AddDataToSection('Director_Name', LocRepMgt.GetEmpName(Employee2));
            ExcelReportBuilderManager.AddDataToSection('Accountant_Name', LocRepMgt.GetEmpName(CompanyInfo."Accountant No."));
            ExcelReportBuilderManager.AddDataToSection('Supplier_Position', LocRepMgt.GetEmpPosition(Employee3));
            ExcelReportBuilderManager.AddDataToSection('Supplier_Name', LocRepMgt.GetEmpName(Employee3));
            ExcelReportBuilderManager.AddDataToSection('Taker_Position', LocRepMgt.GetEmpPosition(Employee4));
            ExcelReportBuilderManager.AddDataToSection('Taker_Name', LocRepMgt.GetEmpName(Employee4));
        end;
    end;
}