page 70261 "Purchase Order Act Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(PurchDetailLine)
            {
                field(FilteredTypeField; TypeAsText)
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    Editable = CurrPageIsEditable;
                    LookupPageID = "Option Lookup List";
                    TableRelation = "Option Lookup Buffer"."Option Caption" WHERE("Lookup Type" = CONST(Purchases));

                    trigger OnValidate()
                    var
                        OldTypeValue: Enum "Purchase Document Type";
                    begin
                        OldTypeValue := Rec."Type";

                        TempOptionLookupBuffer.SetCurrentType(Type.AsInteger());
                        if TempOptionLookupBuffer.AutoCompleteOption(TypeAsText, TempOptionLookupBuffer."Lookup Type"::Purchases) then
                            Validate(Type, TempOptionLookupBuffer.ID);
                        TempOptionLookupBuffer.ValidateOption(TypeAsText);

                        IF OldTypeValue <> Rec."Type" THEN
                            IF Type = Type::Item THEN BEGIN
                                grInventorySetup.GET;
                                grInventorySetup.TESTFIELD("Temp Item Code");
                                VALIDATE("No.", grInventorySetup."Temp Item Code");
                                NoOnAfterValidate();
                            END;

                        UpdateEditableOnRow();
                        UpdateTypeText();
                        DeltaUpdateTotals();
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = Type <> Type::" ";

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();
                        UpdateTypeText();
                        DeltaUpdateTotals();
                    end;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field(Description; "Full Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description/Comment';
                    ShowMandatory = Type <> Type::" ";

                    trigger OnValidate()
                    begin
                        UpdateEditableOnRow();

                        if "No." = xRec."No." then
                            exit;

                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();

                        UpdateTypeText();
                        DeltaUpdateTotals();
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    Editable = NOT IsBlankNumber;
                    Enabled = NOT IsBlankNumber;
                    ShowMandatory = LocationCodeMandatory;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        IF gcERPC.LookUpLocationCode("Location Code") THEN BEGIN
                            VALIDATE("Location Code");
                            DeltaUpdateTotals();
                        END;
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = NOT IsBlankNumber;
                    Enabled = NOT IsBlankNumber;
                    ShowMandatory = (NOT IsCommentLine) AND ("No." <> '');

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = UnitofMeasureCodeIsChangeable;
                    Enabled = UnitofMeasureCodeIsChangeable;
                    ShowMandatory = (NOT IsCommentLine) AND ("No." <> '');

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = NOT IsBlankNumber;
                    Enabled = NOT IsBlankNumber;
                    ShowMandatory = (NOT IsCommentLine) AND ("No." <> '');

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Not VAT"; "Not VAT")
                {
                    ApplicationArea = All;
                    Editable = NOT IsBlankNumber;
                    Enabled = NOT IsBlankNumber;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    // Editable = NOT IsBlankNumber;
                    Editable = false;
                    Enabled = NOT IsBlankNumber;

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    Enabled = NOT IsBlankNumber;
                }

                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = (NOT IsCommentLine) AND ("No." <> '');

                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = (NOT IsCommentLine) AND ("No." <> '');
                }
                field("Utilities Dim. Value Code"; UtilitiesDimValueCode)
                {
                    Caption = 'Utilities Dim. Value Code';
                    CaptionClass = GetAddDimValueCaption(0);
                    ApplicationArea = All;
                    Editable = UtilitiesEnabled;
                    Enabled = UtilitiesEnabled;

                    trigger OnValidate()
                    begin
                        Rec.ValidateAddDimValueCode(UtilitiesDimValueCode, 0);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                    begin
                        GLSetup.GET;
                        IF GLSetup."Utilities Dimension Code" <> '' then begin
                            DimValue.FilterGroup(3);
                            DimValue.SetRange("Dimension Code", GLSetup."Utilities Dimension Code");
                            DimValue.FilterGroup(0);
                            IF page.RunModal(0, DimValue) = Action::LookupOK then begin
                                UtilitiesDimValueCode := DimValue.Code;
                                Rec.ValidateAddDimValueCode(UtilitiesDimValueCode, 0);
                            end;
                        end;
                    end;
                }
                field("Address Dim. Value Code"; AddressDimValueCode)
                {
                    Caption = 'Address Dim. Value Code';
                    CaptionClass = GetAddDimValueCaption(1);
                    ApplicationArea = All;
                    Editable = AddressEnabled;
                    Enabled = AddressEnabled;

                    trigger OnValidate()
                    begin
                        Rec.ValidateAddDimValueCode(AddressDimValueCode, 1);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                    begin
                        GLSetup.GET;
                        IF PurchasesSetup."Address Dimension" <> '' then begin
                            DimValue.FilterGroup(3);
                            DimValue.SetRange("Dimension Code", PurchasesSetup."Address Dimension");
                            DimValue.FilterGroup(0);
                            IF page.RunModal(0, DimValue) = Action::LookupOK then begin
                                AddressDimValueCode := DimValue.Code;
                                Rec.ValidateAddDimValueCode(AddressDimValueCode, 1);
                            end;
                        end;
                    end;
                }
                field(Approver; PaymentOrderMgt.GetPurchActApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Approver';
                }
            }

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
                //group("Related Information")
                //{
                //    Caption = 'Related Information';
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
                //}
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
        GetTotalPurchHeader();
        CalculateTotals();
        UpdateEditableOnRow();
        UpdateTypeText();
        //SetItemChargeFieldsStyle();
        UtilitiesDimValueCode := '';
        IF (GLSetup."Utilities Dimension Code" <> '') and (Rec."Dimension Set ID" <> 0) then
            IF DimSetEntry.GET(Rec."Dimension Set ID", GLSetup."Utilities Dimension Code") then
                UtilitiesDimValueCode := DimSetEntry."Dimension Value Code";
        AddressDimValueCode := '';
        IF (PurchasesSetup."Address Dimension" <> '') and (Rec."Dimension Set ID" <> 0) then
            IF DimSetEntry.GET(Rec."Dimension Set ID", PurchasesSetup."Address Dimension") then
                AddressDimValueCode := DimSetEntry."Dimension Value Code";
        if (PurchaseHeader."Document Type" <> "Document Type") or (PurchaseHeader."No." <> "Document No.") then
            PurchaseHeader.Get("Document Type", "Document No.");
        LocationCodeMandatory := (PurchaseHeader."Act Type" <> PurchaseHeader."Act Type"::Advance) and (not IsCommentLine) AND ("No." <> '');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
        UpdateLCYTotalAmounts();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        DocumentTotals.PurchaseCheckAndClearTotals(Rec, xRec, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        UpdateLCYTotalAmounts();
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        PurchasesSetup.Get();
        AddressEnabled := PurchasesSetup."Address Dimension" <> '';
        Currency.InitRoundingPrecision();
        TempOptionLookupBuffer.FillBuffer(TempOptionLookupBuffer."Lookup Type"::Purchases);
        //IsFoundation := ApplicationAreaMgmtFacade.IsFoundationEnabled();
        GLSetup.Get();
        UtilitiesEnabled := GLSetup."Utilities Dimension Code" <> '';
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        UpdateTypeText();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        DocumentTotals.PurchaseCheckIfDocumentChanged(Rec, xRec);
        UpdateLCYTotalAmounts();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        grInventorySetup: Record "Inventory Setup";
    begin
        InitType();
        SetDefaultType();

        Clear(ShortcutDimCode);
        UpdateTypeText();

        "Forecast Entry" := 0;
        IF NOT PurchaseHeader.GET("Document Type", "Document No.") then
            PurchaseHeader.INIT;
        IF Type = Type::Item THEN BEGIN
            "Location Code" := PurchaseHeader."Location Code";
            IF NOT PurchaseHeader."Location Document" THEN BEGIN
                grInventorySetup.GET;
                grInventorySetup.TESTFIELD("Temp Item Code");
                VALIDATE("No.", grInventorySetup."Temp Item Code");
            END;
        END;
    end;

    var

        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        PurchasesSetup: Record "Purchases & Payables Setup";
        TotalPurchaseHeader: Record "Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        grInventorySetup: Record "Inventory Setup";
        TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
        TotalPurchaseLine: Record "Purchase Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        DocumentTotals: Codeunit "Document Totals";
        gcERPC: Codeunit "ERPC Funtions";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        IsCommentLine, IsBlankNumber : Boolean;
        UnitofMeasureCodeIsChangeable, CurrPageIsEditable, IsSaaSExcelAddinEnabled, UtilitiesEnabled, AddressEnabled : Boolean;
        TypeAsText: Text[30];
        SuppressTotals: Boolean;
        ShortcutDimCode: array[8] of Code[20];
        UtilitiesDimValueCode, AddressDimValueCode : code[20];
        VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct : Decimal;
        LocationCodeMandatory: Boolean;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    local procedure NoOnAfterValidate()
    begin
        UpdateEditableOnRow();
        InsertExtendedText(false);
        if (Type = Type::"Charge (Item)") and ("No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord();
    end;

    local procedure UpdateEditableOnRow()
    begin
        IsCommentLine := Type = Type::" ";
        IsBlankNumber := IsCommentLine;
        UnitofMeasureCodeIsChangeable := Type <> Type::" ";
        CurrPageIsEditable := CurrPage.Editable;
    end;

    local procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            TransferExtendedText.InsertPurchExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            CurrPage.Update(TRUE);
    end;

    local procedure UpdateTypeText()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        TypeAsText := TempOptionLookupBuffer.FormatOption(RecRef.Field(FieldNo(Type)));
    end;

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

    local procedure SetDefaultType()
    begin
        if ApplicationAreaMgmtFacade.IsFoundationEnabled() then
            if xRec."Document No." = '' then
                Type := Type::Item;
    end;
}