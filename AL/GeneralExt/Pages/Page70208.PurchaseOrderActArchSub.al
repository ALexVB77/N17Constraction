page 70208 "Purchase Order Act Arch. Sub."
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Line Archive";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(PurchDetailLine)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;

                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Description; "Full Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description/Comment';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Not VAT"; "Not VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Utilities Dim. Value Code"; UtilitiesDimValueCode)
                {
                    Caption = 'Utilities Dim. Value Code';
                    ApplicationArea = All;
                }
                field(Approver; PaymentOrderMgt.GetPurchActApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Approver';
                }
            }

            // NC AB: look later!
            /*
            group(LineTotals)
            {
                ShowCaption = false;
                fixed(DefiningFixedControl)
                {
                    group(AmountTotals)
                    {
                        Caption = 'Excluding VAT';
                        field(AmountExclVAT; TotalPurchaseLine."Amount")
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            Caption = 'Amount';
                            Editable = false;
                        }
                        field(AmountExclVATLCY; TotalPurchaseLine."Amount (LCY)")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Amount (LCY)';
                            Editable = false;
                        }
                    }
                    group(VATTotals)
                    {
                        Caption = 'VAT';
                        field(VATAmount; TotalPurchaseLine."Amount Including VAT" - TotalPurchaseLine."Amount")
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            //Caption = 'VAT Amount';
                            Editable = false;
                        }
                        field(VATAmountLCY; TotalPurchaseLine."Amount Including VAT (LCY)" - TotalPurchaseLine."Amount (LCY)")
                        {
                            ApplicationArea = Basic, Suite;
                            //Caption = 'VAT Amount (LCY)';
                            Editable = false;
                        }
                    }
                    group(AmtIncVATTotals)
                    {
                        Caption = 'Including VAT';
                        field(AmountIncVAT; TotalPurchaseLine."Amount Including VAT")
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            //Caption = 'Amount Including VAT';
                            Editable = false;
                        }
                        field(AmountIncVATLCY; TotalPurchaseLine."Amount Including VAT (LCY)")
                        {
                            ApplicationArea = Basic, Suite;
                            //Caption = 'Amount Including VAT (LCY)';
                            Editable = false;
                        }
                    }
                }
            }
            */
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction()
                    begin
                        ShowLineComments();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ServerSetting: Codeunit "Server Setting";
    begin
        IsSaaSExcelAddinEnabled := ServerSetting.GetIsSaasExcelAddinEnabled();
        SuppressTotals := CurrentClientType() = ClientType::ODataV4;
    end;

    trigger OnAfterGetCurrRecord()
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        // NC AB: look later!    
        // GetTotalPurchHeader();
        // CalculateTotals();
        UtilitiesDimValueCode := '';
        IF (GLSetup."Utilities Dimension Code" <> '') and (Rec."Dimension Set ID" <> 0) then
            IF DimSetEntry.GET(Rec."Dimension Set ID", GLSetup."Utilities Dimension Code") then
                UtilitiesDimValueCode := DimSetEntry."Dimension Value Code";
        PurchaseHeaderArch.Get("Document Type", "Document No.", "Doc. No. Occurrence", "Version No.");
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // NC AB: look later!
        // DocumentTotals.PurchaseCheckAndClearTotals(Rec, xRec, TotalPurchaseLineArch, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        // UpdateLCYTotalAmounts();
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        PurchasesSetup.Get();
        Currency.InitRoundingPrecision();
        GLSetup.Get();
        UtilitiesEnabled := GLSetup."Utilities Dimension Code" <> '';
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        PurchasesSetup: Record "Purchases & Payables Setup";
        TotalPurchaseHeaderArch: Record "Purchase Header Archive";
        PurchaseHeaderArch: Record "Purchase Header Archive";
        TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
        TotalPurchaseLineArch: Record "Purchase Line Archive";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        DocumentTotals: Codeunit "Document Totals";
        gcERPC: Codeunit "ERPC Funtions";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        IsCommentLine, IsBlankNumber : Boolean;
        UnitofMeasureCodeIsChangeable, CurrPageIsEditable, IsSaaSExcelAddinEnabled, UtilitiesEnabled : Boolean;
        SuppressTotals: Boolean;
        UtilitiesDimValueCode: code[20];
        VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct : Decimal;

    // NC AB: look later!
    /*
    local procedure DeltaUpdateTotals()
    begin
        if SuppressTotals then
            exit;
        DocumentTotals.PurchaseDeltaUpdateTotals(Rec, xRec, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        //CheckSendLineInvoiceDiscountResetNotification();
        UpdateLCYTotalAmounts();
    end;

    local procedure GetTotalPurchHeader()
    begin
        DocumentTotals.GetTotalPurchaseHeaderAndCurrency(Rec, TotalPurchaseHeader, Currency);
        UpdateLCYTotalAmounts();
    end;

    local procedure CalculateTotals()
    begin
        if SuppressTotals then
            exit;

        DocumentTotals.PurchaseCheckIfDocumentChanged(Rec, xRec);
        DocumentTotals.CalculatePurchaseSubPageTotals(
          TotalPurchaseHeader, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        DocumentTotals.RefreshPurchaseLine(Rec);
        UpdateLCYTotalAmounts();
    end;

    local procedure UpdateLCYTotalAmounts()
    var
        CurrExRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
    begin
        if (PurchaseHeader."Document Type" <> "Document Type") or (PurchaseHeader."No." <> "Document No.") then
            PurchaseHeader.Get("Document Type", "Document No.");
        if PurchaseHeader."Currency Code" = '' then begin
            TotalPurchaseLine."Amount Including VAT (LCY)" := TotalPurchaseLine."Amount Including VAT";
            TotalPurchaseLine."Amount (LCY)" := TotalPurchaseLine.Amount;
        end else begin
            Currency.Get(PurchaseHeader."Currency Code");
            TotalPurchaseLine."Amount Including VAT (LCY)" :=
                Round(
                    CurrExRate.ExchangeAmtFCYToLCY(
                        PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TotalPurchaseLine."Amount Including VAT", PurchaseHeader."Currency Factor"),
                Currency."Amount Rounding Precision");
            TotalPurchaseLine."Amount (LCY)" :=
                Round(
                    CurrExRate.ExchangeAmtFCYToLCY(
                        PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TotalPurchaseLine.Amount, PurchaseHeader."Currency Factor"),
                Currency."Amount Rounding Precision");
        end;
    end;
    */
}