page 70006 "Calculation General Journal"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Calculation Journal Line";
    SourceTableView = SORTING(Year, Month, "Journal Template Name", "Journal Batch Name", "Line No.") ORDER(Ascending);
    DataCaptionExpression = 'CalcMonth.Name';
    InsertAllowed = false;
    ModifyAllowed = true;
    SaveValues = true;
    DelayedInsert = true;
    Permissions = TableData "G/L Entry" = rd, TableData "G/L Register" = rimd, TableData "Bank Account Ledger Entry" = rid, TableData "Value Entry" = rimd;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;

                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;

                }
                field("Calculate Record"; Rec."Calculate Record")
                {
                    ApplicationArea = All;
                }
                field("Etry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Calculation Type"; Rec."Calculation Type")
                {
                    ApplicationArea = All;
                }
                field("BegEndSaldo"; Rec.BegEndSaldo)
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("debType"; debType)
                {
                    Caption = 'Debet Account Type';
                    ApplicationArea = All;
                }
                field("Debit Account No."; Rec."Debit Account No.")
                {
                    ApplicationArea = All;
                }
                field("An.View Dimension 1 Filter"; Rec."An.View Dimension 1 Filter")
                {
                    ApplicationArea = All;
                }
                field("CreType"; CreType)
                {
                    Caption = 'Credit Account Type';
                    ApplicationArea = All;
                }
                field("Credit Account No."; Rec."Credit Account No.")
                {
                    ApplicationArea = All;
                }
                field("Calc Some Accounts"; Rec."Calc Some Accounts")
                {
                    ApplicationArea = All;
                }
                field("TypeExRt"; TypeExRt)
                {
                    Caption = 'Exch. Rates Account Type';
                    ApplicationArea = All;
                }
                field("Dim. Allocation"; Rec."Dim. Allocation")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Last Run Date"; Rec."Last Run Date")
                {
                    ApplicationArea = All;
                }
                field("Analysis View Code"; Rec."Analysis View Code")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalcMonth)
            {
                Caption = 'Calc. Month';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    IF SetMonthYear(TRUE) THEN;
                    CurrPage.UPDATE;
                end;
            }
            action(CalculationMarcked)
            {
                Caption = 'Calculation marked';
                ApplicationArea = All;

                trigger OnAction()
                var
                    Rc: Record "Calculation Journal Line";
                    I: Integer;
                begin

                    IF CheckPeriod("Posting Date") THEN EXIT;
                    IF CONFIRM(Text14, FALSE) THEN BEGIN
                        Rc.COPYFILTERS(Rec);
                        Rc.SETRANGE(Rc."Calculate Record", TRUE);
                        GLCalcMgt.RunCalc(Rc, I);
                        MESSAGE(Text29, I);
                        CurrPage.UPDATE(FALSE);
                    END;
                end;
            }
            action(Calculation)
            {
                Caption = 'Calculation';
                ApplicationArea = All;

                trigger OnAction()
                var
                    Rc: Record "Calculation Journal Line";
                    I: Integer;
                begin


                    IF CheckPeriod("Posting Date") THEN EXIT;
                    IF CONFIRM(Text14, FALSE) THEN BEGIN
                        Rc.COPY(Rec);
                        GLCalcMgt.RunCalc(Rc, I);
                        MESSAGE(Text29, I);
                        CurrPage.UPDATE(FALSE);
                    END;
                end;
            }
            action(Insert1)
            {
                Caption = 'Insert';
                ApplicationArea = All;

                trigger OnAction()
                var
                    CalcGenJnlLine: Record "Calculation Journal Line";

                begin

                    CalcGenJnlLine.RESET;
                    CalcGenJnlLine.FILTERGROUP := 2;
                    CalcGenJnlLine.SETRANGE(Year, CalcMonth.Year);
                    CalcGenJnlLine.SETRANGE(Month, CalcMonth.Mes);
                    FILTERGROUP := 2;
                    CalcGenJnlLine.SETFILTER("Journal Template Name", GETFILTER("Journal Template Name"));
                    IF GETFILTER("Journal Batch Name") <> '' THEN
                        CalcGenJnlLine.SETFILTER("Journal Batch Name", GETFILTER("Journal Batch Name"));
                    FILTERGROUP := 0;
                    CalcGenJnlLine.FILTERGROUP := 0;
                    CalcGenJnlLine.SETRANGE("Entry No.", 0);
                    Page.RUNMODAL(50016, CalcGenJnlLine);
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action(Update)
            {
                ApplicationArea = All;
                Caption = 'Undo';
                trigger OnAction()
                var
                    CalcGenJnlLine: Record "Calculation Journal Line";
                begin

                    CalcGenJnlLine.RESET;
                    CalcGenJnlLine.FILTERGROUP := 2;
                    CalcGenJnlLine.SETRANGE(Year, CalcMonth.Year);
                    CalcGenJnlLine.SETRANGE(Month, CalcMonth.Mes);
                    FILTERGROUP := 2;
                    CalcGenJnlLine.SETFILTER("Journal Template Name", GETFILTER("Journal Template Name"));
                    IF GETFILTER("Journal Batch Name") <> '' THEN
                        CalcGenJnlLine.SETFILTER("Journal Batch Name", GETFILTER("Journal Batch Name"));
                    FILTERGROUP := 0;
                    CalcGenJnlLine.FILTERGROUP := 0;
                    CalcGenJnlLine.SETRANGE("Entry No.", "Entry No.");
                    Page.RUNMODAL(50016, CalcGenJnlLine);
                    CurrPage.UPDATE(FALSE);
                end;
            }

            group(Document)
            {
                Caption = 'Document';
                action(DocumentCalculation)
                {
                    Caption = 'Document Calculation';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Flag: Boolean;
                    begin

                        IF CheckPeriod("Posting Date") THEN EXIT;
                        IF Blocked THEN ERROR(Text001, "Document No.");
                        Flag := CONFIRM(Text12, FALSE, "Document No.");
                        IF Flag THEN BEGIN
                            GLCalcMgt.FuncCalcRec(Rec);
                            CurrPage.UPDATE(FALSE);
                        END;

                    end;
                }

            }
            action(ClearCalcRecFields)
            {
                ApplicationArea = All;
                Caption = 'Unmark Calculation';
                trigger OnAction()
                var
                    Rc: Record "Calculation Journal Line";
                begin


                    Rc.RESET;
                    IF Rc.FIND('-') THEN
                        REPEAT
                            Rc."Calculate Record" := FALSE;
                            Rc.MODIFY;
                        UNTIL Rc.NEXT = 0;
                end;
            }
            action(MarkAllCalculations)
            {
                ApplicationArea = All;
                Caption = 'Mark All Calculations';
                trigger OnAction()
                var
                    Rc: Record "Calculation Journal Line";
                begin


                    Rc.RESET;
                    IF Rc.FIND('-') THEN
                        REPEAT
                            Rc."Calculate Record" := TRUE;
                            Rc.MODIFY;
                        UNTIL Rc.NEXT = 0;
                end;
            }
            action(MarkChosenCalculations)
            {
                ShortcutKey = 'Ctrl+S';
                ApplicationArea = All;
                Caption = 'Mark Chosen Calculations';
                trigger OnAction()
                var
                    CJL: Record "Calculation Journal Line";
                begin
                    CurrPage.SETSELECTIONFILTER(CJL);
                    CJL.MODIFYALL("Calculate Record", TRUE);
                end;
            }
            action(UnmarkChosenCalculations)
            {
                ShortcutKey = 'Ctrl+D';
                ApplicationArea = All;
                Caption = 'Unmark Chosen Calculations';
                trigger OnAction()
                var
                    CJL: Record "Calculation Journal Line";
                begin
                    CurrPage.SETSELECTIONFILTER(CJL);
                    CJL.MODIFYALL("Calculate Record", false);
                end;
            }
            action(DocumentBlockOnOF)
            {
                ApplicationArea = All;
                Caption = 'Block Document';
                trigger OnAction()
                var
                    Rc: Record "Calculation Journal Line";
                begin

                    IF Rc.GET("Entry No.") THEN BEGIN
                        Rc.VALIDATE(Blocked, NOT Rc.Blocked);
                        Rc.LOCKTABLE;
                        Rc.MODIFY;
                        COMMIT;
                        CurrPage.UPDATE(FALSE);
                    END;
                end;
            }
            action(CopyDocument)
            {
                ShortcutKey = 'F5';
                ApplicationArea = All;
                Caption = 'Copy Document';
                trigger OnAction()
                var
                    CGenJnlLine: Record "Calculation Journal Line";
                    CGenJnl: Record "Calculation Journal Line";
                    CopyCalcJnlLine: Record "Calculation Journal Line";
                begin

                    //Копировать документ
                    CurrPage.SETSELECTIONFILTER(CopyCalcJnlLine);
                    IF CopyCalcJnlLine.FINDSET THEN
                        REPEAT
                            IF CONFIRM(Text34, FALSE, "Document No.") THEN BEGIN
                                GLCalcMgt.CopyDocument(CopyCalcJnlLine, CGenJnlLine);
                                COMMIT;
                                IF CopyCalcJnlLine.COUNT = 1 THEN BEGIN
                                    GET(CGenJnlLine."Entry No.");
                                    CGenJnlLine.RESET;
                                    CGenJnlLine.FILTERGROUP := 2;
                                    CGenJnlLine.SETRANGE(Year, Year);
                                    CGenJnlLine.SETRANGE(Month, Month);
                                    CGenJnlLine.SETRANGE("Journal Template Name", "Journal Template Name");
                                    FILTERGROUP := 2;
                                    IF GETFILTER("Journal Batch Name") <> '' THEN
                                        CGenJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
                                    FILTERGROUP := 0;
                                    CGenJnlLine.FILTERGROUP := 0;
                                    CGenJnlLine.SETRANGE("Entry No.", "Entry No.");
                                    Page.RUNMODAL(Page::"Calc. Gen. Journal Update", CGenJnlLine);
                                    CurrPage.UPDATE(FALSE);
                                END;
                            END;

                        UNTIL CopyCalcJnlLine.NEXT = 0;
                end;
            }


        }



    }

    var
        GenJnlMgt: Codeunit 230;
        CurrentJnlBatchName: Code[10];
        GenJnlBatch: Record 232;
        TypeExRt: Option " ","G/L Account","Bank Account";
        DebType: Option " ","G/L Account","Bank Account";
        CreType: Option " ","G/L Account","Bank Account";
        Mail: Codeunit 397;
        DateRun: Date;
        TimeRun: Time;
        FlagRun: Boolean;
        TempBatchNm: Code[10];
        TempDocNo: Code[20];
        TempPostDate: Date;
        GLCalcMgt: Codeunit "G/L Calculation Management";
        DimAlloc: Record "Calc. Gen Journal Operand";
        CalcMonth: Record "Calculation Month";
        //CalcMonthForm: Page 50013;
        //Text01: Label 'Документ No %1 \';
        //Text02: Label '%2 должен быть задан.';
        //Text03: Label 'Условие выполнения не задано.';
        //Text04: Label 'В операнде %2 не найден %3 %4.';
        //Text05: Label 'У Счета %2 нет измерения %3.';
        //Text051: Label 'Измерения не могут быть использованы с Счетом %2.';
        //Text061: Label 'Счет %2 не раскрывается по Измерениям %3,%4,%5.';
        //Text07: Label 'Расчет суммы не задан.';
        //Text08: Label 'ENU=Analyzing Data...\\;RUS=Удаление      @1@@@@@@@@@@@@@@\';
        //Text09: Label 'ENU=Analyzing Data...\\;RUS=Расчет               @2@@@@@@@@@@@@@@\';
        //Text10: Label 'RUS=%2 должен быть %3,%4,%5.';
        //Text11: Label 'ENU=Calc. Indirect Cost;RUS=Расчет Косвенных Издержек';
        Text12: Label 'Рассчитать Документ No. %1?';
        //"Text12-1": Label 'RUS=Обновить Строки в Документах Связанных с Шаблоном %1?';
        //"Text12-2": Label 'RUS=Обновить Строки в Документе No. %1 из Шаблона?';
        Text14: Label 'Calculate All Docunments?';
        //Text15: Label 'RUS=Расчет Документа No. #3##############\';
        //"Text15-1": Label 'RUS=Обновление Строк в Документах Связанных с Шаблоном\@1@@@@@@@@@@@@@@';
        //Text16: Label 'RUS=Документа No. #3##############\';
        //Text17: Label 'RUS=Конечное Сальдо Счета No. %2 равно 0.';
        //Text18: Label 'ENU=Calculation;RUS=Расчет';
        Text19: Label 'Account %2 Should have type %3';
        //Text20: Label 'RUS=Выпуск по Произ.Заказу No.%2 не найден';
        //Text22: Label 'RUS=Не найден Запущенный Произ. Заказ No. %2';
        //Text23: Label 'RUS=Общая Себестоимость по Складу %2 равна 0.';
        Text001: Label 'Document No. %1 is Blocked.';
        //Text24: Label 'RUS=%2 не может быть %3.';
        //Text25: Label 'RUS=Не найдены измерения %2';
        //Text26: Label 'RUS=Не найдены счета при группировке счетов';
        //Text27: Label 'RUS=Нет записей в таблице %2';
        Text28: Label 'Closed Period';
        Text29: Label 'Calculated %1 documents.';
        //Text30: Label 'RUS=В счете No. %2 не указана валюта.';
        //Text31: Label 'RUS=Счет No. %2 должен быть Активным или Пассивным';
        //Text32: Label 'RUS=Не найден курс %2 на %3';
        //Text33: Label 'RUS=В валюте %2 не задан %3';
        Text34: Label 'Копировать Документ No.%1?';
    //Text35: Label 'RUS=%2 должен быть задан в документе или в строках базы.';
    //Text36: Label 'RUS=%2 в строках базы не может быть %3.';
    //Text37: Label 'RUS=Сохранение           @4@@@@@@@@@@@@@@\';
    //Text38: Label 'RUS=Измерения %1 и %2 должны быть разными.';
    //Text39: Label 'RUS=Неверно поставлены Скобки в формуле Условия.';
    //Text407: Label 'RUS=Неверно поставлены Скобки в формуле Суммы.';

    //Text41: Label 'RUS=Дата запуска расчета %1 меньше текущей даты %2';
    //Text42: Label 'RUS=Время запуска расчета %1 уже прошло. Сейчас %2';
    //Text43: Label 'RUS=Запустить расчет %1 в %2?';
    //Text44: Label 'RUS=Списание Себестоимости';
    //Text45: Label 'ENU=Analyzing Data...\\;RUS=Товар No.            #4###################\';
    //Text46: Label 'ENU=Analyzing Data...\\;RUS=Склад                #5###################\';

    procedure RunCalc(VAR Rc: Record "Calculation Journal Line"; VAR I: Integer)
    var

    begin
        //Расчет нескольких документов

        I := 0;
        IF Rc.FIND('-') THEN    //Расчет
            REPEAT
                IF NOT Rc.Blocked THEN BEGIN
                    GLCalcMgt.RunCalc(Rc, I);
                    I += 1;
                END;
            UNTIL Rc.NEXT = 0;
    end;

    procedure SetMonthYear(FlaqRec: Boolean): Boolean
    var

    begin
        Message('P 50015 SetMonthYear Func');
        /*
        CLEAR(CalcMonthForm);
        CalcMonthForm.LOOKUPMODE(TRUE);
        IF FlagRec THEN CalcMonthForm.SavRec(CalcMonth);
        IF CalcMonthForm.RUNMODAL = ACTION::LookupOK THEN BEGIN
           CalcMonthForm.GETRECORD(CalcMonth);
           //CurrForm.UPDATECONTROLS;
           FILTERGROUP := 2;
           SETRANGE(Year,CalcMonth.Year);
           SETRANGE(Month,CalcMonth.Mes);
           FILTERGROUP := 0;
           EXIT(TRUE);
        END;
        EXIT(FALSE);
         */
    end;

    /*procedure FuncCalcRec(VAR Rc: Record 70045; VAR I: Integer)
    var

    begin
        //Расчет нескольких документов


        CASE Rc."Calculation Type" OF  //Тип Документа
            Rc."Calculation Type"::Calculation:
                BEGIN  //Расчет
                    Rc.LOCKTABLE;
                    CalcRec(Rc);
                END;
        END;
        Rc.MODIFY;
        COMMIT;
    end;

    procedure CalcRec(VAR Rc: Record 70045)
    var

    begin

    end;*/
    procedure CheckPeriod(D: date): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
    begin

        AccountingPeriod."Starting Date" := NORMALDATE(D);
        IF AccountingPeriod.FIND('=<') AND AccountingPeriod.Closed THEN BEGIN
            MESSAGE(Text28);
            EXIT(TRUE);
        END;
        EXIT(FALSE);
    end;


}
