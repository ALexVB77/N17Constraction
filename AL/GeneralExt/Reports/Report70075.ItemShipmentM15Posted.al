report 70075 "Item Shipment M-15 Posted"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Item Shipment M-15 Posted';

    dataset
    {
        dataitem(TransferReceiptHeader; "Transfer Receipt Header")
        {
            DataItemTableView = sorting("No.");

            dataitem(TransferReceiptLine; "Transfer Receipt Line")
            {
                DataItemTableView = sorting("Document No.", "Line No.");
                DataItemLink = "Document No." = field("No.");

                trigger OnPreDataItem()
                begin
                    i := 0;
                end;

                trigger OnAfterGetRecord()
                var
                    ILE: Record "Item Ledger Entry";
                begin
                    i += 1;

                    BalAccount := '';
                    InvPostingSetup.Reset();
                    InvPostingSetup.SetRange("Location Code", "Transfer-from Code");
                    InvPostingSetup.SetRange("Invt. Posting Group Code", "Inventory Posting Group");
                    if InvPostingSetup.FindSet() then
                        BalAccount := InvPostingSetup."Inventory Account";

                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        Clear(UnitOfMeasure);

                    ItemDescription := Description + "Description 2";

                    if ILE.Get("Item Rcpt. Entry No.") then begin
                        ILE.CalcFields("Cost Amount (Actual)");
                        UnitCostTxt := Format(Abs(ILE."Cost Amount (Actual)" / ILE.Quantity), 0, '<Precision,2:2><Standard Format,0>');
                        AmountTxt := Format(Abs(ILE."Cost Amount (Actual)"), 0, '<Precision,2:2><Standard Format,0>');
                        TotalAmount += Abs(ILE."Cost Amount (Actual)");
                    end;

                    if not PrintPrice then begin
                        UnitCostTxt := '-';
                        AmountTxt := '-';
                    end;

                    Qty1Txt := Format(Quantity);
                    Qty2Txt := Format(Quantity);

                    txtItemNo := "Item No.";
                    if "Variant Code" <> '' then
                        txtItemNo := txtItemNo + '(' + "Variant Code" + ')';
                end;
            }

            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);

                trigger OnAfterGetRecord()
                begin
                    TotalAmountTxt := LocalManagement.Amount2Text('', TotalAmount);
                    TotalVATAmountTxt := LocalManagement.Amount2Text('', VATAmount);
                    if not PrintPrice then begin
                        TotalAmountTxt := '-';
                        TotalVATAmountTxt := '-';
                    end;
                end;
            }

            trigger OnPreDataItem()
            begin
                if GetFilters() = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                ConsignorTmp: Text;
                TransferRcptLine: Record "Transfer Receipt Line";
                Bin: Record "Bin";
            begin
                Consignor := "Transfer-from Code";
                if Location.Get(Consignor) then
                    Consignor := Consignor + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                Consignee := "Transfer-to Code";
                if Location.Get(Consignee) then
                    Consignee := Consignee + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                TransferRcptLine.Reset();
                TransferRcptLine.SetRange("Document No.", "No.");
                TransferRcptLine.SetFilter("Transfer-To Bin Code", '<>%1', '');

                if TransferRcptLine.FindFirst() then begin
                    Bin.Get(TransferRcptLine."Transfer-to Code", TransferRcptLine."Transfer-To Bin Code");
                    Consignee := Bin.Code;
                    if Bin.Description <> '' then
                        Consignee := Bin.Description;
                end;

                if Vendor.Get("No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.Get("Vendor No.", "Agreement No.") then
                        ReasonName3 := StrSubstNo(Text12401, VendorAgreement."External Agreement No.");
                end;

                FillHeader("No.", "Posting Date");
            end;
        }

        dataitem(TransferHeader; "Transfer Header")
        {
            DataItemTableView = sorting("No.");
            dataitem(TransferLine; "Transfer Line")
            {
                DataItemTableView = sorting("Document No.", "Line No.") where("Derived From Line No." = const(0));
                DataItemLink = "Document No." = field("No.");

                trigger OnPreDataItem()
                begin
                    i := 0;
                end;

                trigger OnAfterGetRecord()
                var
                    TransferLineReserve: Codeunit "Transfer Line-Reserve";
                    ReservEntry: Record "Reservation Entry";
                    ILE: Record "Item Ledger Entry";
                    ILEQuantity: Decimal;
                    Amount: Decimal;
                    VATPostingSetup: Record "VAT Posting Setup";
                    VAT: Decimal;
                    AmountIncVAT: Decimal;
                    Direction: Enum "Transfer Direction";
                    Item: Record Item;
                begin
                    i += 1;

                    BalAccount := '';
                    InvPostingSetup.Reset();
                    InvPostingSetup.SetRange("Location Code", "Transfer-from Code");
                    InvPostingSetup.SetRange("Invt. Posting Group Code", "Inventory Posting Group");
                    if InvPostingSetup.FindSet() then
                        BalAccount := InvPostingSetup."Inventory Account";

                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        Clear(UnitOfMeasure);

                    ItemDescription := Description + "Description 2";

                    Clear(UnitCostTxt);
                    Clear(AmountTxt);
                    Clear(VATAmountTxt);
                    Clear(IncVATAmountTxt);

                    TransferLine.SetReservationFilters(ReservEntry, Direction::Outbound);

                    if Quantity <> 0 then
                        if ReservEntry.FindFirst() then
                            if ReservEntry.Get(ReservEntry."Entry No.", not ReservEntry.Positive) then
                                if ILE.Get(ReservEntry."Source Ref. No.") then begin
                                    if ILE.Quantity = 0 then
                                        ILEQuantity := 1
                                    else
                                        ILEQuantity := ILE.Quantity;

                                    ILE.CalcFields(ILE."Cost Amount (Expected)", ILE."Cost Amount (Actual)");
                                    Amount := ILE."Cost Amount (Expected)" + ILE."Cost Amount (Actual)";
                                    Amount := Amount / ILEQuantity * Quantity;

                                    if Item.Get("Item No.") and Vendor.Get(TransferHeader."Vendor No.") then
                                        if VATPostingSetup.Get(Vendor."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                                            VAT := Round(Amount * VATPostingSetup."VAT %" / 100);

                                    AmountIncVAT := Amount + VAT;
                                    VATAmount += VAT;
                                    TotalAmount += AmountIncVAT;

                                    if Quantity <> 0 then
                                        UnitCostTxt := Format(Amount / Quantity, 0, '<Precision,2:2><Standard Format,0>');

                                    AmountTxt := Format(Amount, 0, '<Precision,2:2><Standard Format,0>');
                                    VATAmountTxt := Format(VAT, 0, '<Precision,2:2><Standard Format,0>');
                                    IncVATAmountTxt := Format(AmountIncVAT, 0, '<Precision,2:2><Standard Format,0>');

                                end;

                    if not PrintPrice then begin
                        UnitCostTxt := '-';
                        AmountTxt := '-';
                        VATAmountTxt := '-';
                        IncVATAmountTxt := '-';
                    end;

                    Qty1Txt := Format(Quantity);
                    Qty2Txt := Format(Quantity);

                    txtItemNo := "Item No.";

                    if "Variant Code" <> '' then
                        txtItemNo := txtItemNo + '(' + "Variant Code" + ')';

                    FillBody("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Unit of Measure Code");
                end;

                trigger OnPostDataItem()
                begin
                    TotalAmountTxt := LocalManagement.Amount2Text('', TotalAmount);
                    TotalVATAmountTxt := LocalManagement.Amount2Text('', VATAmount);
                    if not PrintPrice then begin
                        TotalAmountTxt := '-';
                        TotalVATAmountTxt := '-';
                    end;

                    FillFooter();
                end;
            }


            trigger OnPreDataItem()
            begin
                if GetFilters = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                TransferLine: Record "Transfer Line";
                ConsignorTmp: Text;
                Bin: Record Bin;
            begin
                Consignor := "Transfer-from Code";
                if Location.Get(Consignor) then
                    Consignor := Consignor + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                Consignee := "Transfer-to Code";
                if Location.Get(Consignee) then
                    Consignee := Consignee + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                TransferLine.Reset();
                ;
                TransferLine.SetRange("Document No.", "No.");
                TransferLine.SetFilter("Transfer-To Bin Code", '<>%1', '');

                if TransferLine.FindFirst() then begin
                    Bin.Get(TransferLine."Transfer-to Code", TransferLine."Transfer-To Bin Code");
                    Consignee := Bin.Code;
                    if Bin.Description <> '' then
                        Consignee := Bin.Description;
                end;

                if Vendor.Get("Vendor No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.Get("Vendor No.", "Agreement No.") then
                        ReasonName3 := STRSUBSTNO(Text12401, VendorAgreement."External Agreement No.");
                end;

                if Vendor.GET("Vendor No.") then
                    Consignee := Vendor."Full Name";

                FillHeader("No.", "Posting Date");
            end;
        }

        dataitem(ItemDocHeader; "Item Document Header")
        {
            DataItemTableView = sorting("Document Type", "No.") order(ascending) where("Document Type" = const(Shipment));
            dataitem(ItemDocLine; "Item Document Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") order(ascending);
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");

                trigger OnPreDataItem()
                begin
                    i := 0;
                end;

                trigger OnAfterGetRecord()
                var
                    ILE: Record "Item Ledger Entry";
                begin
                    i += 1;
                    BalAccount := '';
                    InvPostingSetup.Reset();
                    InvPostingSetup.SetRange("Location Code", "Location Code");
                    InvPostingSetup.SetRange("Invt. Posting Group Code", "Inventory Posting Group");

                    if InvPostingSetup.FindSet() then
                        BalAccount := InvPostingSetup."Inventory Account";

                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        Clear(UnitOfMeasure);

                    ItemDescription := Description;

                    if ILE.Get("Applies-from Entry") then begin
                        ILE.CalcFields("Cost Amount (Actual)");
                        UnitCostTxt := Format(Abs(ILE."Cost Amount (Actual)" / ILE.Quantity), 0, '<Precision,2:2><Standard Format,0>');
                        AmountTxt := Format(Abs(ILE."Cost Amount (Actual)"), 0, '<Precision,2:2><Standard Format,0>');
                        TotalAmount += Abs(ILE."Cost Amount (Actual)");
                    end;

                    if not PrintPrice then begin
                        UnitCostTxt := '-';
                        AmountTxt := '-';
                    end;

                    Qty1Txt := Format(Quantity);
                    Qty2Txt := Format(Quantity);

                    txtItemNo := "Item No.";
                    if "Variant Code" <> '' then
                        txtItemNo := txtItemNo + '(' + "Variant Code" + ')';

                    FillBody("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Unit of Measure Code");
                end;

                trigger OnPostDataItem()
                begin
                    TotalAmountTxt := LocalManagement.Amount2Text('', TotalAmount);
                    TotalVATAmountTxt := LocalManagement.Amount2Text('', VATAmount);
                    if not PrintPrice then begin
                        TotalAmountTxt := '-';
                        TotalVATAmountTxt := '-';
                    end;

                    FillFooter();
                end;
            }

            trigger OnPreDataItem()
            begin
                if GetFilters = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                Consignor := "Location Code";
                if Vendor.Get("Vendor No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.Get("Vendor No.", "Agreement No.") then
                        ReasonName3 := StrSubstNo(Text12401, VendorAgreement."External Agreement No.");
                end;

                if Location.Get(Consignor) then
                    Consignor := Consignor + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                FillHeader("No.", "Posting Date");
            end;
        }

        dataitem(ItemShipmentHeader; "Item Shipment Header")
        {
            DataItemTableView = sorting("No.");
            dataitem(ItemShipmentLine; "Item Shipment Line")
            {
                DataItemTableView = sorting("Document No.", "Line No.");
                DataItemLink = "Document No." = field("No.");

                trigger OnPreDataItem()
                begin
                    i := 0;
                end;

                trigger OnAfterGetRecord()
                var
                    ILE: Record "Item Ledger Entry";
                begin
                    i += 1;
                    BalAccount := '';
                    InvPostingSetup.Reset();
                    InvPostingSetup.SetRange("Location Code", "Location Code");
                    InvPostingSetup.SetRange("Invt. Posting Group Code", "Inventory Posting Group");

                    if InvPostingSetup.FindSet() then
                        BalAccount := InvPostingSetup."Inventory Account";

                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        Clear(UnitOfMeasure);

                    ItemDescription := Description;

                    if ILE.Get("Item Shpt. Entry No.") then begin
                        ILE.CalcFields("Cost Amount (Actual)");
                        UnitCostTxt := Format(Abs(ILE."Cost Amount (Actual)" / ILE.Quantity), 0, '<Precision,2:2><Standard Format,0>');
                        AmountTxt := Format(Abs(ILE."Cost Amount (Actual)"), 0, '<Precision,2:2><Standard Format,0>');
                        TotalAmount += Abs(ILE."Cost Amount (Actual)");
                    end;

                    if not PrintPrice then begin
                        UnitCostTxt := '-';
                        AmountTxt := '-';
                    end;

                    Qty1Txt := Format(Quantity);
                    Qty2Txt := Format(Quantity);

                    txtItemNo := "Item No.";
                    if "Variant Code" <> '' then
                        txtItemNo := txtItemNo + '(' + "Variant Code" + ')';

                    FillBody("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Unit of Measure Code");
                end;

                trigger OnPostDataItem()
                begin
                    TotalAmountTxt := LocalManagement.Amount2Text('', TotalAmount);
                    TotalVATAmountTxt := LocalManagement.Amount2Text('', VATAmount);
                    if not PrintPrice then begin
                        TotalAmountTxt := '-';
                        TotalVATAmountTxt := '-';
                    end;

                    FillFooter();
                end;
            }

            trigger OnPreDataItem()
            begin
                if GetFilters = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                Consignor := "Location Code";

                if Vendor.Get("Vendor No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.Get("Vendor No.", "Agreement No.") then
                        ReasonName3 := StrSubstNo(Text12401, VendorAgreement."External Agreement No.");
                end;

                if Location.Get(Consignor) then
                    Consignor := Consignor + ' ' + Location.Name + ', ' + Location.Address + ' ' + Location."Address 2";

                if Vendor.Get("Vendor No.") then begin
                    Consignee := Vendor.Name;
                    if VendorAgreement.Get("Vendor No.", "Agreement No.") then
                        ReasonName3 := StrSubstNo(Text12401, "Agreement No.");
                END;

                FillHeader("No.", "Posting Date");
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
                    field(PrintPrice; PrintPrice)
                    {
                        ApplicationArea = All;
                        Caption = 'Print with Price';
                    }
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
            }
        }

        trigger OnOpenPage()
        begin
            PrintPrice := true;
            ExportToExcel := true;
        end;
    }

    var
        Consignor: Text;
        Location: Record "Location";
        Consignee: Text;
        Vendor: Record "Vendor";
        VendorAgreement: Record "Vendor Agreement";
        ReasonName3: Text;
        Text12401: Label 'By agreement %1';
        ExportToExcel: Boolean;
        LocRepMgt: Codeunit "Local Report Management";
        CompanyInfo: Record "Company Information";
        PrintPrice: Boolean;
        i: Integer;
        BalAccount: Code[20];
        InvPostingSetup: Record "Inventory Posting Setup";
        UnitOfMeasure: Record "Unit of Measure";
        ItemDescription: Text;
        UnitCostTxt: Text;
        AmountTxt: Text;
        TotalAmount: Decimal;
        Qty1Txt: Text;
        Qty2Txt: Text;
        txtItemNo: Code[20];
        TotalAmountTxt: Text;
        TotalVATAmountTxt: Text;
        LocalManagement: Codeunit "Localisation Management";
        VATAmount: Decimal;
        VATAmountTxt: Text;
        IncVATAmountTxt: Text;
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        FileName: Text;
        Employee2: Code[20];
        Employee3: Code[20];
        Employee4: Code[20];

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        InitReportTemplate();
    end;

    trigger OnPostReport()
    begin
        if FileName = '' then
            ExcelReportBuilderManager.ExportData
        else
            ExcelReportBuilderManager.ExportDataToClientFile(FileName);
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

    local procedure InitReportTemplate()
    begin
        ExcelReportBuilderManager.InitTemplate('М-15-Н');
        ExcelReportBuilderManager.SetSheet('Sheet1');
    end;
}