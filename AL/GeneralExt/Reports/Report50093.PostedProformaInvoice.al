report 50093 "Posted Proforma Invoice"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = './Reports/Layouts/PostedProformaInvoice.docx';

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            // column(ColumnName; SourceFieldName)
            // {

            // }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(CopiesNumber; CopiesNumber)
                    {
                        ApplicationArea = All;
                        Caption = 'Copies Number';
                    }
                    field(CurrencyPriceAmount; CurrencyPriceAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';
                    }
                    field(ShowDiscount; ShowDiscount)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Discount';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = All;
                        Caption = 'Log Interaction';
                    }
                    field(ExportExcel; ExportExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Excel';
                    }
                }
            }

        }
        trigger OnOpenPage()
        begin

            if CopiesNumber < 1 then
                CopiesNumber := 1;
        end;

        // actions
        // {
        //     area(processing)
        //     {
        //         action(ActionName)
        //         {
        //             ApplicationArea = All;

        //         }
        //     }
        // }
    }

    var

        // ShipmentMethod	Record	Shipment Method	
        // PaymentTerms	Record	Payment Terms	
        // CompanyInfo	Record	Company Information	
        // Currency	Record	Currency	
        // Cust	Record	Customer	
        // Manager	Record	Salesperson/Purchaser	
        // SalesLine1	Record	Sales Invoice Line	
        // SalesRecSetup	Record	Sales & Receivables Setup	
        // PrintingCounter	Codeunit	Sales Inv.-Printed	
        // AddressFormat	Codeunit	Format Address	
        // NoSeriesManagement	Codeunit	NoSeriesManagement	
        // LocMgt	Codeunit	Localisation Management	
        // StandRepManagement	Codeunit	Local Report Management	
        // SegManagement	Codeunit	SegManagement	
        // DateNameInvoice	Date		
        CurrencyPriceAmount: Option "Валюте счета",Рублях,"Рублях и валюте счета";
        // CurrentCurrencyAmountPrice	Option		
        // ExcludingDiscount	Boolean		
        ShowDiscount: Boolean;
        // AmountInclVAT	Boolean		
        // LinesWereFinished	Boolean		
        // NewInvoce	Boolean		
        // TitleDoc	Text		100
        // CustomerAddr	Text		90
        // CompanyAddress	Text		90
        // PageHeader	Text		100
        // InclVAT	Text		11
        // CurrencyCode	Text		10
        // CurrencyExchRate	Text		30
        // ManagerText	Text		30
        // ReportValue	Text		30
        // TotalAmount	Decimal		
        // LastTotalAmount	Decimal		
        // AmountInvDiscount	Decimal		
        // DecPointCourse	Integer		
        CopiesNumber: Integer;
        // ItemLineNo	Integer		
        // OrderedNo.	Integer		
        // CurrencyForAmountWritten	Code		10
        // FirstStep	Boolean		
        // DocumentType	Option		
        // QtyType	Option		
        // Ind	Option		
        // Ins	Option		
        // PayComment	Text		250
        LogInteraction: Boolean;
        // UnitPrice	Decimal		
        // UnitPriceLCY	Decimal		
        // CustAgr	Record	Customer Agreement	
        ExportExcel: Boolean;
    // ExcelTemplates	Record	Excel Templates	
    // EB	Record	Excel Buffer	
    // RowNo	Integer		
    // FileName	Text		250
}