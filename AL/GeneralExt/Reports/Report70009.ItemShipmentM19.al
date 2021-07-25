report 70009 "Item Shipment M-19"
{
    // NC22512
    // NC 52624 EP
    //  перенес объект

    Caption = 'Item Shipment M-19';
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(ItemDocHeader; "Item Document Header")
        {
            DataItemTableView = sorting("Document Type", "No.") order(ascending) where("Document Type" = const(Shipment));

            dataitem(ItemDocLine; "Item Document Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") order(ascending);
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");

                trigger OnAfterGetRecord()
                begin
                    //NC 22512 > DP
                    FillBodyID(ItemDocLine);
                    //NC 22512 < DP
                end;

                trigger OnPostDataItem()
                begin
                    //NC 22512 > DP
                    FillFooter();
                    //NC 22512 < DP
                end;
            }

            trigger OnPreDataItem()
            begin
                //NC 22512 > DP
                if ItemDocHeader.GetFilters() = '' then CurrReport.Break();
                //NC 22512 < DP
            end;

            trigger OnAfterGetRecord()
            begin
                //NC 22512 > DP
                Location.Get(ItemDocHeader."Location Code");
                PurchaserCode := ItemDocHeader."Salesperson/Purchaser Code";
                FillHeader();

                ILE.SetFilter("Posting Date", '<1%', ItemDocHeader."Posting Date");
                VE.SetFilter("Posting Date", '<1%', ItemDocHeader."Posting Date");
                ILE.SetRange("Location Code", ItemDocHeader."Location Code");
                VE.SetRange("Location Code", ItemDocHeader."Location Code");
                //NC 22512 < DP
            end;
        }
        dataitem("Item Shipment Header"; "Item Shipment Header")
        {
            DataitemTableView = sorting("No.");

            dataitem("Item Shipment Line"; "Item Shipment Line")
            {
                DataItemTableView = sorting("Document No.", "Line No.");
                DataItemLink = "Document No." = field("No.");

                trigger OnAfterGetRecord()
                var
                    IDL: Record "Item Document Line";
                begin
                    //NC 22512 > DP
                    IDL.TransferFields("Item Shipment Line");
                    FillBodyID(IDL);
                    //NC 22512 < DP
                end;

                trigger OnPostDataItem()
                begin
                    //NC 22512 > DP
                    FillFooter();
                    //NC 22512 < DP
                end;
            }

            trigger OnPreDataItem()
            begin
                //NC 22512 > DP
                if "Item Shipment Header".GetFilters() = '' then CurrReport.Break();
                //NC 22512 < DP
            end;

            trigger OnAfterGetRecord()
            begin
                //NC 22512 > DP
                Location.Get("Item Shipment Header"."Location Code");
                PurchaserCode := "Item Shipment Header"."Salesperson Code";
                FillHeader();

                ILE.SetFilter("Posting Date", '<%1', "Item Shipment Header"."Posting Date");
                VE.SetFilter("Posting Date", '<%1', "Item Shipment Header"."Posting Date");
                ILE.SetRange("Location Code", "Item Shipment Header"."Location Code");
                VE.SetRange("Location Code", "Item Shipment Header"."Location Code");
                //NC 22512 < DP
            end;
        }
    }


    requestpage
    {
        Caption = 'Item Shipment M-15 Posted';
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Employee2; Employee2)
                    {
                        ApplicationArea = All;
                        Caption = 'Project Manager';
                        TableRelation = Employee;
                    }
                    field(Employee3; Employee3)
                    {
                        ApplicationArea = All;
                        Caption = 'Report verified by';
                        TableRelation = Employee;
                    }
                    field(ReportDate; ReportDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Report Date';
                        // NC 52624 > EP
                        // Ну это мем какой-то, отключил
                        // TableRelation = Employee;
                        // NC 52624 < EP
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ReportDate := WorkDate();
        end;
    }

    trigger OnPreReport()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // NC 52624 > EP
        // FileName := ExcelTemplate.OpenTemplate(Format(Report::"Item Shipment M-19"));
        // ExcelBuf.OpenBook(FileName, 'Sheet1');
        // RowNo := 24;
        InventorySetup.Get();
        InventorySetup.TestField("Item Shpt. M-19 Template Code");
        ExcelReportBuilderManager.InitTemplate(InventorySetup."Item Shpt. M-19 Template Code");
        ExcelReportBuilderManager.SetSheet('Sheet1');
        // NC 52624 < EP

        ILE.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        // NC 52624 > EP
        // VE.SetCurrentKey("Item No.","Location Code","Expected Cost",Inventoriable,"Posting Date");
        VE.SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
        // NC 52624 < EP
        if ReportDate = 0D then ReportDate := WorkDate();
    end;

    trigger OnPostReport()
    begin
        // NC 52624 > EP
        // ExcelBuf.SaveCellsToExcel();
        // ExcelBuf.GiveUserControl();

        ExcelReportBuilderManager.ExportData();
        // NC 52624 < EP
    end;

    var
        Location: Record Location;
        ILE: Record "Item Ledger Entry";
        VE: Record "Value Entry";
        ExcelTemplate: Record "Excel Template";
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        LocRepMgt: Codeunit "Local Report Management";
        LocalManagement: Codeunit "Localisation Management";
        Employee2: Code[20];
        Employee3: Code[20];
        PurchaserCode: Code[20];
        ReportDate: Date;
        TotalItemAmount: Decimal;
        TotalLineAmount: Decimal;
        TotalEndAmount: Decimal;
        Text0001: Label 'по учету материально-производственные запасов  на строительной площадке %1', Comment = '%1 = Location Name';


    procedure FillHeader()
    begin
        // NC 52624 > EP

        /* //NC 22512 > DP
            ExcelBuf.AddCell(7, 7, LocRepMgt.GetEmpName(Employee2), FALSE, FALSE, FALSE, 9);
            ExcelBuf.AddCell(7, 26, LocRepMgt.GetEmpName(Employee3), FALSE, FALSE, FALSE, 9);

            ExcelBuf.AddCell(16, 8, STRSUBSTNO(Text0001, Location.Name + Location."Name 2"), FALSE, FALSE, FALSE, 9);

            ExcelBuf.AddCell(20, 12, FORMAT(DATE2DMY(ReportDate, 1)), FALSE, FALSE, FALSE, 9);
            ExcelBuf.AddCell(20, 14, LocalManagement.Month2Text(ReportDate), FALSE, FALSE, FALSE, 9);
            ExcelBuf.AddCell(20, 19, FORMAT(DATE2DMY(ReportDate, 3)), FALSE, FALSE, FALSE, 9);
            //NC 22512 < DP
        */

        ExcelReportBuilderManager.AddSection('Header');

        ExcelReportBuilderManager.AddDataToSection('ProjectManager', LocRepMgt.GetEmpName(Employee2));
        ExcelReportBuilderManager.AddDataToSection('ReportInspector', LocRepMgt.GetEmpName(Employee3));

        ExcelReportBuilderManager.AddDataToSection('ConstructionSiteDescription', StrSubstNo(Text0001, Location.Name + Location."Name 2"));

        ExcelReportBuilderManager.AddDataToSection('ReportDay', Format(Date2DMY(ReportDate, 1)));
        ExcelReportBuilderManager.AddDataToSection('ReportMonth', LocalManagement.Month2Text(ReportDate));
        ExcelReportBuilderManager.AddDataToSection('ReportYear', Format(Date2DMY(ReportDate, 3)));
        // NC 52624 < EP
    end;

    procedure FillFooter()
    begin
        // NC 52624 > EP

        /* //NC 22512 > DP

            ExcelBuf.DeleteString(RowNo - 1);

            //RowNo += 1;

            ExcelBuf.AddCell(RowNo, 18, ReportFormat(TotalItemAmount), FALSE, FALSE, FALSE, 7);
            ExcelBuf.AddCell(RowNo, 23, ReportFormat(TotalLineAmount), FALSE, FALSE, FALSE, 7);
            ExcelBuf.AddCell(RowNo, 28, ReportFormat(TotalEndAmount), FALSE, FALSE, FALSE, 7);

            RowNo += 6;
            ExcelBuf.AddCell(RowNo, 8, Text0002, FALSE, FALSE, FALSE, 9);
            ExcelBuf.AddCell(RowNo, 13, PurchaserCode, FALSE, FALSE, FALSE, 9);
            ExcelBuf.AddCell(RowNo, 22, Text0003, FALSE, FALSE, FALSE, 9);

            //NC 22512 < DP
        */

        ExcelReportBuilderManager.AddSection('Footer');

        ExcelReportBuilderManager.AddDataToSection('TotalItemAmount', ReportFormat(TotalItemAmount));
        ExcelReportBuilderManager.AddDataToSection('TotalLineAmount', ReportFormat(TotalLineAmount));
        ExcelReportBuilderManager.AddDataToSection('TotalEndAmount', ReportFormat(TotalEndAmount));

        ExcelReportBuilderManager.AddDataToSection('PurchaserCode', PurchaserCode);
        // NC 52624 < EP
    end;

    procedure FillBodyID(IDL: Record "Item Document Line")
    var
        Item: Record Item;
        ItemAmount: Decimal;
        LineAmount: Decimal;
        EndAmount: Decimal;
    begin
        // NC 52624 > EP

        /* //NC 22512 > DP
            WITH IDL DO BEGIN
                Item.GET("Item No.");
                ILE.SETRANGE("Item No.", "Item No.");
                VE.SETRANGE("Item No.", "Item No.");
                ILE.CALCSUMS(Quantity);
                VE.CALCSUMS("Cost Amount (Actual)");

                ItemAmount := VE."Cost Amount (Actual)";
                Amount := ItemAmount;

                TotalItemAmount += ItemAmount;
                TotalLineAmount += Amount;
                TotalEndAmount += EndAmount;

                ExcelBuf.InsertString(RowNo);
                ExcelBuf.AddCell(RowNo, 1, "Item No.", FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 3, Description, FALSE, FALSE, FALSE, 7);

                ExcelBuf.AddCell(RowNo, 12, ReportFormat(Item."Unit Cost"), FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 14, "Unit of Measure Code", FALSE, FALSE, FALSE, 6);

                ExcelBuf.AddCell(RowNo, 16, ReportFormat(Quantity), FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 18, ReportFormat(Amount), FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 21, ReportFormat(Quantity), FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 23, ReportFormat(Amount), FALSE, FALSE, FALSE, 7);

                ExcelBuf.AddCell(RowNo, 26, ReportFormat(0), FALSE, FALSE, FALSE, 7);
                ExcelBuf.AddCell(RowNo, 28, ReportFormat(EndAmount), FALSE, FALSE, FALSE, 7);
                RowNo += 1;
            END;
            //NC 22512 < DP
        */

        Item.Get(IDL."Item No.");
        ILE.SetRange("Item No.", IDL."Item No.");
        VE.SetRange("Item No.", IDL."Item No.");
        ILE.CalcSums(Quantity);
        VE.CalcSums("Cost Amount (Actual)");

        ItemAmount := VE."Cost Amount (Actual)";
        IDL.Amount := ItemAmount;

        TotalItemAmount += ItemAmount;
        TotalLineAmount += IDL.Amount;
        TotalEndAmount += EndAmount;

        ExcelReportBuilderManager.AddSection('Body');

        ExcelReportBuilderManager.AddDataToSection('ItemNo', IDL."Item No.");
        ExcelReportBuilderManager.AddDataToSection('ItemDescription', IDL.Description);

        ExcelReportBuilderManager.AddDataToSection('ItemUnitCost', ReportFormat(Item."Unit Cost"));
        ExcelReportBuilderManager.AddDataToSection('UnitOfMeasureCode', IDL."Unit of Measure Code");

        ExcelReportBuilderManager.AddDataToSection('QuantityBalance', ReportFormat(IDL.Quantity));
        ExcelReportBuilderManager.AddDataToSection('AmountBalance', ReportFormat(IDL.Amount));
        ExcelReportBuilderManager.AddDataToSection('QuantityUsed', ReportFormat(IDL.Quantity));
        ExcelReportBuilderManager.AddDataToSection('AmountUsed', ReportFormat(IDL.Amount));

        ExcelReportBuilderManager.AddDataToSection('QuantityLeft', ReportFormat(0));
        ExcelReportBuilderManager.AddDataToSection('AmountLeft', ReportFormat(EndAmount));
        // NC 52624 < EP
    end;

    procedure ReportFormat(dec: Decimal): Text[250]
    begin
        exit(Format(dec, 0, '<Precision,2:2><Standard Format,0>'));
    end;
}