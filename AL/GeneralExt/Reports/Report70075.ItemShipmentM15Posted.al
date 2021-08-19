report 70075 "Item Shipment M-15"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Item Shipment M-15';

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
                MaxIteration = 1;

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

                FillHeader("No.",
                    "Posting Date",
                    Format(GetCostCodeName(1, TransferHeader."Shortcut Dimension 1 Code")),
                    Format(GetCostCodeName(1, TransferHeader."New Shortcut Dimension 1 Code")));
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

                FillHeader("No.",
                    "Posting Date",
                    Format(GetCostCodeName(1, TransferHeader."Shortcut Dimension 1 Code")),
                    Format(GetCostCodeName(1, TransferHeader."New Shortcut Dimension 1 Code")));
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

                FillHeader("No.",
                    "Posting Date",
                    Format(GetCostCodeName(1, TransferHeader."Shortcut Dimension 1 Code")),
                    Format(GetCostCodeName(1, TransferHeader."New Shortcut Dimension 1 Code")));
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

                FillHeader("No.",
                    "Posting Date",
                    Format(GetCostCodeName(1, TransferHeader."Shortcut Dimension 1 Code")),
                    Format(GetCostCodeName(1, TransferHeader."New Shortcut Dimension 1 Code")));
            end;
        }

        dataitem(TransferShipmentHeader; "Transfer Shipment Header")
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
                    var
                        Currency: Record "Currency";
                    begin
                        Currency.InitRoundingPrecision;
                        i := 0;
                    end;

                    trigger OnAfterGetRecord()
                    var
                        LastTotalAmount: array[8] of Decimal;
                        TotalAmountArray: array[8] of Decimal;
                        BalAccNo: Code[20];
                        Amount: Decimal;
                        Item: Record Item;
                        VATPostingSetup: Record "VAT Posting Setup";
                        VAT: Decimal;
                        AmountIncVAT: Decimal;
                    begin
                        if Number = 1 then begin
                            if not SalesLine1.FindSet() then
                                CurrReport.Break();
                        end else
                            if SalesLine1.Next(1) = 0 then
                                CurrReport.Break();

                        CopyArray(LastTotalAmount, TotalAmountArray, 1);

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
                    var
                        LocMgt: Codeunit "Localisation Management";
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

                trigger OnAfterGetRecord()
                begin
                    Clear(TotalAmount);
                end;
            }

            trigger OnPreDataItem()
            begin
                if GetFilters = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                LineCount: Integer;
                PassedBy: Record "Posted Document Signature";
                ApprovedBy: Record "Posted Document Signature";
                ReleasedBy: Record "Posted Document Signature";
                ReceivedBy: Record "Posted Document Signature";
                RequestedBy: Record "Posted Document Signature";
                TransferShipmentLine: Record "Transfer Shipment Line";
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                CompanyInfo.Get;

                LineCount := SalesLine1.Count;

                CheckSignature(PassedBy, PassedBy."Employee Type"::PassedBy);
                CheckSignature(ApprovedBy, PassedBy."Employee Type"::Responsible);
                CheckSignature(ReleasedBy, ReleasedBy."Employee Type"::ReleasedBy);
                CheckSignature(ReceivedBy, ReceivedBy."Employee Type"::ReceivedBy);
                CheckSignature(RequestedBy, ReceivedBy."Employee Type"::RequestedBy);

                TransferShipmentLine.Reset();
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

                FillHeader("No.",
                    "Posting Date",
                    Format(GetCostCodeName(1, TransferShipmentHeader."Shortcut Dimension 1 Code")),
                    Format(GetCostCodeName(1, TransferShipmentHeader."New Shortcut Dimension 1 Code")));
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
        SalesLine1: Record "Sales Line" temporary;
        TotalAmount1: Decimal;

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

    local procedure InitReportTemplate()
    begin
        ExcelReportBuilderManager.InitTemplate('М-15-Н');
        ExcelReportBuilderManager.SetSheet('Sheet1');
    end;

    local procedure CheckSignature(var DocSign: Record "Posted Document Signature"; EmpType: Integer)
    var
        InvSetup: Record "Inventory Setup";
        DocSignMgt: Codeunit "Doc. Signature Management";
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

    local procedure FillHeader(DocNo: Code[20]; PostingDate: Date; SenderStructDpt: Text; ReceiverStructDpt: Text)
    begin
        if not ExcelReportBuilderManager.TryAddSection('REPORTHEADER') then begin
            ExcelReportBuilderManager.AddPagebreak;
            ExcelReportBuilderManager.AddSection('REPORTHEADER');
        end;
        ExcelReportBuilderManager.AddDataToSection('InvoiceID', Format(DocNo));
        ExcelReportBuilderManager.AddDataToSection('Organisation', Format(LocRepMgt.GetCompanyName()));
        ExcelReportBuilderManager.AddDataToSection('OKPO', Format(CompanyInfo."OKPO Code"));
        ExcelReportBuilderManager.AddDataToSection('InvoiceDate', Format(PostingDate));
        ExcelReportBuilderManager.AddDataToSection('Sender_StructDpt', SenderStructDpt);
        ExcelReportBuilderManager.AddDataToSection('Receiver_StructDpt', ReceiverStructDpt);
        ExcelReportBuilderManager.AddDataToSection('InvoiceBasis', Format(ReasonName3));
        ExcelReportBuilderManager.AddDataToSection('Header_ToWhom', Format(Consignee));

        if not ExcelReportBuilderManager.TryAddSection('PAGEHEADER') then begin
            ExcelReportBuilderManager.AddPagebreak;
            ExcelReportBuilderManager.AddSection('PAGEHEADER');
        end;
    end;

    local procedure FillBody(ShortcutDimension1Code: Code[20]; ShortcutDimension2Code: Code[20]; UnitofMeasureCode: Code[20])
    begin
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
    end;

    local procedure FillFooter()
    begin
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
}