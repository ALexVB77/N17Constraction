page 50097 "Item G/L Turnover GE"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Item G/L Turnover GE';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View by';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        FindPeriod('');
                        CurrPage.Update;
                    end;
                }
                field(WithoutTransfer; WithoutTransfer)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Without transfers';
                }
                field(ShowBlocked; ShowBlocked)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show blocked';
                    trigger OnValidate()
                    begin
                        //NC 22512 > DP
                        SetFiltres();
                        CurrPage.UPDATE;
                        //NC 22512 < DP
                    end;
                }
            }
            repeater(Matrix)
            {
                Editable = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description associated with this line.';
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                }
                field(StartingQuantity; StartingQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Starting Quantity';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(0, 0);
                    end;
                }
                field(DebitQuantity; DebitQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Debit Quantity';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1, 0);
                    end;
                }
                field(CreditQuantity; CreditQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Credit Quantity';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2, 0);
                    end;
                }
                field(EndingQuantity; EndingQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Ending Quantity';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3, 0);
                    end;
                }
                field(StartingCost; StartingCost)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Starting Cost';

                    trigger OnDrillDown()
                    begin
                        DrillDown(0, 1);
                    end;
                }
                field(DebitCost; DebitCost)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Debit Cost';
                    ToolTip = 'Specifies information about the cost of the item and is calculated on the basis of the cost amounts posted in the general ledger entry.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(1, 1);
                    end;
                }
                field(CreditCost; CreditCost)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Credit Cost';

                    trigger OnDrillDown()
                    begin
                        DrillDown(2, 1);
                    end;
                }
                field(EndingCost; EndingCost)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ending Cost';

                    trigger OnDrillDown()
                    begin
                        DrillDown(3, 1);
                    end;
                }
                field(StartingCostExpect; StartingCostExpect)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Starting Cost (Expected)';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        DrillDownExpect(0, 1);
                    end;

                }
                field(DebitCostExpect; DebitCostExpect)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Debit Cost (Expected)';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        DrillDownExpect(1, 1);
                    end;

                }
                field(CreditCostExpect; CreditCostExpect)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Credit Cost (Expected)';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        DrillDownExpect(2, 1);
                    end;

                }
                field(EndingCostExpect; EndingCostExpect)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ending Cost (Expected)';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        DrillDownExpect(3, 1);
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
        area(processing)
        {
            action("Previous Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Previous Period';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Period';

                trigger OnAction()
                begin
                    FindPeriod('<=');
                end;
            }
            action("Next Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next Period';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Period';

                trigger OnAction()
                begin
                    FindPeriod('>=');
                end;
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Turnover Sheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Turnover Sheet';
                    Image = Turnover;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ToolTip = 'View the fixed asset turnover information. You can view information such as the fixed asset name, quantity, status, depreciation dates, and amounts. The report can be used as documentation for the correction of quantities and for auditing purposes.';

                    trigger OnAction()
                    begin
                        Item.Copy(Rec);
                        REPORT.RunModal(REPORT::"Item Turnover (Qty.)", true, false, Item);
                    end;
                }
            }
        }
        area(reporting)
        {
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcBalance;
    end;

    trigger OnOpenPage()
    begin

        //NC 22512 > DP
        SetFiltres();
        //NC 22512 < DP
        if PeriodType = PeriodType::"Accounting Period" then
            FindPeriodUser('')
        else
            FindPeriod('');
    end;

    var
        UserSetup: Record "User Setup";
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        StartDateFilter: Text[50];
        EndDateFilter: Text[50];
        DebitQuantity: Decimal;
        CreditQuantity: Decimal;
        StartingQuantity: Decimal;
        EndingQuantity: Decimal;
        DebitCost: Decimal;
        CreditCost: Decimal;
        StartingCost: Decimal;
        EndingCost: Decimal;
        WithoutTransfer: Boolean;
        ShowBlocked: Boolean;
        DebitCostExpect: Decimal;
        CreditCostExpect: Decimal;
        StartingCostExpect: Decimal;
        EndingCostExpect: Decimal;
        ValueEntryExpect: Record "Value Entry";

    local procedure FindPeriod(SearchText: Code[10])
    var
        Calendar: Record Date;
        PeriodFormManagement: Codeunit PeriodFormManagement;
    begin
        if GetFilter("Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
            if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
        SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
        if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
            SetRange("Date Filter", GetRangeMin("Date Filter"));

        CalcFilters;
    end;

    [Scope('OnPrem')]
    procedure CalcBalance()
    begin
        DebitQuantity := 0;
        CreditQuantity := 0;
        StartingQuantity := 0;
        EndingQuantity := 0;

        ValueEntry.Reset();
        ValueEntry.SetCurrentKey(
          "Item No.", "Location Code",
          "Global Dimension 1 Code", "Global Dimension 2 Code",
          "Expected Cost", Positive, "Posting Date", "Red Storno");
        ValueEntry.SetRange("Item No.", "No.");
        ValueEntry.SetRange("Expected Cost", false);
        CopyFilter("Global Dimension 1 Filter", ValueEntry."Global Dimension 1 Code");
        CopyFilter("Global Dimension 2 Filter", ValueEntry."Global Dimension 2 Code");
        CopyFilter("Location Filter", ValueEntry."Location Code");
        CopyFilter("Date Filter", ValueEntry."Posting Date");

        // MC IK 20120307 >>
        IF WithoutTransfer THEN
            ValueEntry.SETFILTER("Item Ledger Entry Type", '<>%1', ValueEntry."Item Ledger Entry Type"::Transfer)
        ELSE
            ValueEntry.SETRANGE("Item Ledger Entry Type");
        // MC IK 20120307 >>

        //NC 22512 > DP
        ValueEntryExpect.RESET;
        ValueEntryExpect.COPY(ValueEntry);
        ValueEntryExpect.SETRANGE("Expected Cost");
        //CalculateAmounts(ValueEntry,DebitCost,CreditCost,DebitQuantity,CreditQuantity);
        CalculateAmounts(ValueEntry, DebitCost, CreditCost, DebitQuantity, CreditQuantity,
                         DebitCostExpect, CreditCostExpect);
        //NC 22512 < DP


        if EndDateFilter <> '' then
            ValueEntry.SetFilter("Posting Date", EndDateFilter);
        ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");

        //NC 22512 > DP
        IF EndDateFilter <> '' THEN
            ValueEntryExpect.SETFILTER("Posting Date", EndDateFilter);
        ValueEntryExpect.CALCSUMS("Cost Amount (Expected)");
        EndingCostExpect := ValueEntryExpect."Cost Amount (Expected)";
        //NC 22512 < DP
        EndingQuantity := ValueEntry."Invoiced Quantity";
        EndingCost := ValueEntry."Cost Amount (Actual)";

        //NC 22512 > DP
        StartingCostExpect := 0;
        //NC 22512 < DP
        StartingQuantity := 0;
        StartingCost := 0;
        if StartDateFilter <> '' then begin
            ValueEntry.SetFilter("Posting Date", StartDateFilter);
            ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");

            //NC 22512 > DP
            ValueEntryExpect.SETFILTER("Posting Date", StartDateFilter);
            ValueEntryExpect.CALCSUMS("Cost Amount (Expected)");
            StartingCostExpect := ValueEntryExpect."Cost Amount (Expected)";
            //NC 22512 > DP
            StartingQuantity := ValueEntry."Invoiced Quantity";
            StartingCost := ValueEntry."Cost Amount (Actual)";
        end;
    end;

    local procedure FindPeriodUser(SearchText: Code[10])
    var
        Calendar: Record Date;
        PeriodFormManagement: Codeunit PeriodFormManagement;
    begin
        if UserSetup.Get(UserId) then begin
            SetRange("Date Filter", UserSetup."Allow Posting From", UserSetup."Allow Posting To");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end else begin
            if GetFilter("Date Filter") <> '' then begin
                Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
                if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                    PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
                Calendar.SetRange("Period Start");
            end;
            PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
            SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end;
    end;

    [Scope('OnPrem')]
    procedure DrillDown(Show: Option Start,Debit,Credit,Ending; Value: Option Quantity,Cost)
    var
        TempValueEntry: Record "Value Entry" temporary;
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey(
          "Item No.", "Location Code",
          "Global Dimension 1 Code", "Global Dimension 2 Code",
          "Expected Cost", Positive, "Posting Date");
        ValueEntry.SetRange("Item No.", "No.");
        ValueEntry.SetFilter("Location Code", GetFilter("Location Filter"));
        ValueEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));

        // MC IK 20120307 >>
        IF WithoutTransfer THEN
            ValueEntry.SETFILTER("Item Ledger Entry Type", '<>%1', ValueEntry."Item Ledger Entry Type"::Transfer)
        ELSE
            ValueEntry.SETRANGE("Item Ledger Entry Type");
        // MC IK 20120307 >>
        case Show of
            Show::Start:
                ValueEntry.SetFilter("Posting Date", StartDateFilter);
            Show::Debit, Show::Credit:
                FillTempValueEntry(Show, TempValueEntry);
            Show::Ending:
                ValueEntry.SetFilter("Posting Date", EndDateFilter);
        end;
        ValueEntry.SetRange("Expected Cost", false);

        if (Show = Show::Debit) or (Show = Show::Credit) then
            if Value = Value::Quantity then
                PAGE.Run(0, TempValueEntry, TempValueEntry."Invoiced Quantity")
            else
                PAGE.Run(0, TempValueEntry, TempValueEntry."Cost Amount (Actual)")
        else
            if Value = Value::Quantity then
                PAGE.Run(0, ValueEntry, ValueEntry."Invoiced Quantity")
            else
                PAGE.Run(0, ValueEntry, ValueEntry."Cost Amount (Actual)");
    end;

    [Scope('OnPrem')]
    procedure CalcFilters()
    begin
        StartDateFilter := '';
        EndDateFilter := '';
        if GetFilter("Date Filter") <> '' then begin
            EndDateFilter := StrSubstNo('..%1', GetRangeMax("Date Filter"));
            if GetRangeMin("Date Filter") > 0D then
                StartDateFilter := StrSubstNo('..%1', CalcDate('<-1D>', GetRangeMin("Date Filter")));
        end;
    end;

    [Scope('OnPrem')]
    procedure FillTempValueEntry(Show: Option Start,Debit,Credit,Ending; var TempValueEntry: Record "Value Entry" temporary)
    begin
        TempValueEntry.CopyFilters(ValueEntry);
        TempValueEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
        if ValueEntry.FindSet then
            repeat
                TempValueEntry.Init();
                TempValueEntry := ValueEntry;
                if ((Show = Show::Debit) and TempValueEntry.IsDebit) or
                   ((Show = Show::Credit) and not TempValueEntry.IsDebit)
                then
                    if TempValueEntry.Insert() then;
            until ValueEntry.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalculateAmounts(var ValueEntry: Record "Value Entry"; var DebitCost: Decimal; var CreditCost: Decimal; var DebitQty: Decimal; var CreditQty: Decimal; var DebitCostExcept: Decimal; var CreditCostExcept: Decimal)
    var
        TempValueEntry: Record "Value Entry";
    begin
        TempValueEntry.CopyFilters(ValueEntry);

        DebitCost := 0;
        CreditCost := 0;
        DebitQty := 0;
        CreditQty := 0;

        //NC 22512 > DP
        DebitCostExcept := 0;
        CreditCostExcept := 0;
        //NC 22512 < DP
        with TempValueEntry do
            if FindSet then
                repeat
                    if IsDebit then begin
                        DebitCost := DebitCost + "Cost Amount (Actual)";
                        DebitQty := DebitQty + "Invoiced Quantity";
                    end else begin
                        CreditCost := CreditCost - "Cost Amount (Actual)";
                        CreditQty := CreditQty - "Invoiced Quantity";
                    end;
                until Next = 0;

        //NC 22512 > DP
        TempValueEntry.COPYFILTERS(ValueEntryExpect);
        WITH TempValueEntry DO
            IF FINDSET THEN
                REPEAT
                    IF IsDebitExpect(TempValueEntry) THEN BEGIN
                        DebitCostExcept := DebitCostExcept + "Cost Amount (Expected)"
                    END ELSE BEGIN
                        CreditCostExcept := CreditCostExcept - "Cost Amount (Expected)"
                    END;
                UNTIL NEXT = 0;
        //NC 22512 < DP
    end;

    procedure SetFiltres()
    begin

        //NC 22512 > DP
        IF NOT ShowBlocked THEN
            SETRANGE(Blocked, ShowBlocked)
        ELSE
            SETRANGE(Blocked);
        //NC 22512 < DP
    end;

    procedure IsDebitExpect(var ve: Record "Value Entry"): Boolean
    begin

        //NC22512 > DP
        //EXIT(("Cost Amount (Actual)" > 0) XOR "Red Storno");
        // MC IK 20121026 >>
        EXIT((ve."Cost Amount (Expected)" >= 0) XOR ve."Red Storno");
        // MC IK 20121026 <<
        //NC22512 < DP

    end;

    procedure DrillDownExpect(Show: Option Start,Debit,Credit,Ending; Value: Option Quantity,Cost)
    var
        TempValueEntry: Record "Value Entry" temporary;
    begin

        //NC 22512 > DP
        ValueEntry.RESET;
        ValueEntry.SETCURRENTKEY(
          "Item No.", "Location Code",
          "Global Dimension 1 Code", "Global Dimension 2 Code",
          "Expected Cost", Positive, "Posting Date");
        ValueEntry.SETRANGE("Item No.", "No.");
        ValueEntry.SETFILTER("Location Code", GETFILTER("Location Filter"));
        ValueEntry.SETFILTER("Global Dimension 1 Code", GETFILTER("Global Dimension 1 Filter"));
        // MC IK 20120307 >>
        IF WithoutTransfer THEN
            ValueEntry.SETFILTER("Item Ledger Entry Type", '<>%1', ValueEntry."Item Ledger Entry Type"::Transfer)
        ELSE
            ValueEntry.SETRANGE("Item Ledger Entry Type");
        // MC IK 20120307 >>
        ValueEntry.SETFILTER("Cost Amount (Expected)", '<>%1', 0);
        CASE Show OF
            Show::Start:
                ValueEntry.SETFILTER("Posting Date", StartDateFilter);
            //  Show::Debit,Show::Credit:
            //  FillTempValueEntry(Show,TempValueEntry);
            Show::Debit:
                ValueEntry.SETFILTER("Cost Amount (Expected)", '>%1', 0);
            Show::Credit:
                ValueEntry.SETFILTER("Cost Amount (Expected)", '<%1', 0);
            Show::Ending:
                ValueEntry.SETFILTER("Posting Date", EndDateFilter);
        END;
        //ValueEntry.SETRANGE("Expected Cost",FALSE);


        IF (Show = Show::Debit) OR (Show = Show::Credit) THEN
            IF Value = Value::Quantity THEN
                //PAGE.RUN(0,TempValueEntry,TempValueEntry."Invoiced Quantity")
                page.RUN(0, ValueEntry, ValueEntry."Invoiced Quantity")
            ELSE
                //PAGE.RUN(0,TempValueEntry,TempValueEntry."Cost Amount (Expected)")
                PAGE.RUN(0, ValueEntry, ValueEntry."Cost Amount (Expected)")
        ELSE
            IF Value = Value::Quantity THEN
                PAGE.RUN(0, ValueEntry, ValueEntry."Invoiced Quantity")
            ELSE
                PAGE.RUN(0, ValueEntry, ValueEntry."Cost Amount (Expected)");
        //NC 22512 < DP

    end;
}
