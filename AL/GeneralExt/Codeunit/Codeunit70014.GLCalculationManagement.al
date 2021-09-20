codeunit 70014 "G/L Calculation Management"

{

    trigger OnRun()
    begin

    end;

    procedure RunCalc(var Rc: Record "Calculation Journal Line"; var I: Integer)
    var

    begin


        //Расчет нескольких документов

        I := 0;
        IF Rc.FIND('-') THEN    //Расчет
            REPEAT
                IF NOT Rc.Blocked THEN BEGIN
                    FuncCalcRec(Rc);
                    I += 1;
                END;
            UNTIL Rc.NEXT = 0;
    end;

    procedure FuncCalcRec(var Rc: Record "Calculation Journal Line")
    var

    begin

        case Rc."Calculation Type" of  //Тип Документа
            Rc."Calculation Type"::Calculation, Rc."Calculation Type"::"Item Allocation":
                begin
                    //Расчет
                    Rc.LockTable();
                    CalcRec(Rc);
                end;
        end;
        Rc.Modify();
    end;

    procedure CalcRec(var Rc: Record "Calculation Journal Line")
    var

    begin
        Message('CU 70023 CalcRec func');
        /*

        //Расчет документа
        Rc.TESTFIELD("G/L Journal Template Name");
        Rc.TESTFIELD("G/L Journal Batch Name");
        CLEAR(GenJnlPostLine);
        IF Rc."Debit Account No." = '' THEN BEGIN
           MESSAGE(Text01 + Text02,Rc."Document No.",Rc.FIELDCAPTION("Debit Account No."));
           EXIT;
        END;

        IF Rc."Credit Account No." = '' THEN BEGIN
          // NC 29379 >>
          CGenJnlOper.RESET;
          CGenJnlOper.SETCURRENTKEY("Calc. Gen. Jnl. Entry No.","Type Operation","Line No.");
          CGenJnlOper.SETRANGE("Calc. Gen. Jnl. Entry No.",Rc."Entry No.");
          CGenJnlOper.SETRANGE("Type Operation",CGenJnlOper."Type Operation"::DimDistribute);
          CGenJnlOper.SETFILTER("Credit Account No.",'%1','');
          IF NOT CGenJnlOper.ISEMPTY THEN BEGIN
            MESSAGE(Text01 + Text50002,Rc."Document No.",Rc.FIELDCAPTION("Credit Account No."));
            EXIT;
          END;
          CGenJnlOper.SETRANGE("Credit Account No.");
          IF CGenJnlOper.FINDSET THEN
           REPEAT
             CGenJnlOper.SETRANGE("Dimension 1 Value Code",CGenJnlOper."Dimension 1 Value Code");
             IF CGenJnlOper.COUNT > 1 THEN BEGIN
               MESSAGE(Text01 + Text50001,Rc."Document No.",CGenJnlOper."Dimension 1 Code",CGenJnlOper."Dimension 1 Value Code");
               EXIT;
             END;
             CGenJnlOper.SETRANGE("Dimension 1 Value Code");
           UNTIL CGenJnlOper.NEXT = 0;
          // NC 29379 <<
        //   MESSAGE(Text01 + Text02,Rc."Document No.",Rc.FIELDCAPTION("Credit Account No."));
        //   EXIT;
        END;

        GLSetup.GET;
        IF GLSetup."Additional Reporting Currency" <> '' THEN
           Currency.GET(GLSetup."Additional Reporting Currency");

        SourceCodeSetup.GET;


        Window.OPEN(Text15 + Text09);
        Window.UPDATE(2,0);
        Window.UPDATE(3,Rc."Document No.");

        OpNo := 0;
        Tran1 := 0;
        Tran2 := 0;
        ColTotal := 1;
        i:=0;
        //Измерения

        CGenJnlOper.RESET;
        CGenJnlOper.SETCURRENTKEY("Calc. Gen. Jnl. Entry No.","Type Operation","Line No.");
        CGenJnlOper.SETRANGE("Calc. Gen. Jnl. Entry No.",Rc."Entry No.");
        CGenJnlOper.SETRANGE("Type Operation",CGenJnlOper."Type Operation"::Condition);
        IF CGenJnlOper.FIND('-') THEN BEGIN  //Проверка Скобок
           Lv := 0;      //Уровень Скобки
           REPEAT
             IF CGenJnlOper."Opening Bracket" THEN Lv += 1;
             IF CGenJnlOper."Closing Bracket" THEN Lv -= 1;
             IF Lv < 0 THEN BEGIN
                MESSAGE(Text01 + Text39,Rc."Document No.");
                Window.CLOSE;
                EXIT;
             END;
           UNTIL CGenJnlOper.NEXT = 0;
        END ELSE BEGIN
           MESSAGE(Text01 + Text03,Rc."Document No.");
           Window.CLOSE;
           EXIT;
        END;

        CGenJnlOper.SETRANGE("Type Operation",CGenJnlOper."Type Operation"::SummaLCY);
        IF CGenJnlOper.FIND('-') THEN BEGIN  //Проверка Скобок
           Lv := 0;      //Уровень Скобки
           REPEAT
             IF CGenJnlOper."Opening Bracket" THEN Lv += 1;
             IF CGenJnlOper."Closing Bracket" THEN Lv -= 1;
             IF Lv < 0 THEN BEGIN
                MESSAGE(Text01 + Text40,Rc."Document No.");
                Window.CLOSE;
                EXIT;
             END;
           UNTIL CGenJnlOper.NEXT = 0;
        END ELSE BEGIN
           MESSAGE(Text01 + Text07,Rc."Document No.");
           Window.CLOSE;
           EXIT;
        END;
        //функциональность временно закомментирована, как не актуальная
        //CopyAnalysisDimValuesToTemp(Rc);
        CGenJnlOper.SETRANGE("Type Operation");

        ColTotal := ColTotal * CGenJnlOper.COUNT;

        IF NOT AnalysisView.GET(Rc."Analysis View Code") THEN;
        AnalysisViewEntryCount.SETRANGE("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntryCount.SETRANGE("Posting Date", 0D,  Rc."Posting Date");
        AnalysisViewColTotal:=AnalysisViewEntryCount.COUNT*CGenJnlOper.COUNT;
        //функциональность временно закомментирована, как не актуальная
        // Всегда расчет только по аналитическому отчету
        //
        {
        IF AnalysisViewColTotal * 2 < ColTotal THEN
          CalculationMethod:= CalculationMethod::ByAnalysisView
           ELSE
          CalculationMethod:= CalculationMethod::ByDimensions;
        }
        CalculationMethod:= CalculationMethod::ByAnalysisView;
        ColTotal:=AnalysisViewColTotal;
        //функциональность временно закомментирована, как не актуальная
        IF CalculationMethod = CalculationMethod::ByAnalysisView THEN
         BEGIN
           AnalysisViewEntryTemp.RESET;
           AnalysisViewEntryTemp.DELETEALL;
           AnalysisViewEntryCount.SETFILTER("Dimension 1 Value Code", Rc."An.View Dimension 1 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 2 Value Code", Rc."An.View Dimension 2 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 3 Value Code", Rc."An.View Dimension 3 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 4 Value Code", Rc."An.View Dimension 4 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 5 Value Code", Rc."An.View Dimension 5 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 6 Value Code", Rc."An.View Dimension 6 Filter");
           // MC IK 20120608 >>
           AnalysisViewEntryCount.SETFILTER("Dimension 7 Value Code", Rc."An.View Dimension 7 Filter");
           AnalysisViewEntryCount.SETFILTER("Dimension 8 Value Code", Rc."An.View Dimension 8 Filter");
           // MC IK 20120608 <<
           IF AnalysisViewEntryCount.FINDSET THEN
            REPEAT
              AnalysisViewEntryTemp."Dimension 1 Value Code":=AnalysisViewEntryCount."Dimension 1 Value Code";
              AnalysisViewEntryTemp."Dimension 2 Value Code":=AnalysisViewEntryCount."Dimension 2 Value Code";
              AnalysisViewEntryTemp."Dimension 3 Value Code":=AnalysisViewEntryCount."Dimension 3 Value Code";
              AnalysisViewEntryTemp."Dimension 4 Value Code":=AnalysisViewEntryCount."Dimension 4 Value Code";
              AnalysisViewEntryTemp."Dimension 5 Value Code":=AnalysisViewEntryCount."Dimension 5 Value Code";
              AnalysisViewEntryTemp."Dimension 6 Value Code":=AnalysisViewEntryCount."Dimension 6 Value Code";
              // MC IK 20120608 >>
              AnalysisViewEntryTemp."Dimension 7 Value Code":=AnalysisViewEntryCount."Dimension 7 Value Code";
              AnalysisViewEntryTemp."Dimension 8 Value Code":=AnalysisViewEntryCount."Dimension 8 Value Code";
              // MC IK 20120608 <<
              IF AnalysisViewEntryTemp.INSERT THEN;
            UNTIL AnalysisViewEntryCount.NEXT =0;
         END;
        /// >> NCC002-FD-016 CITRU\KART 20120127
        //Temporary Code, no time
        /// << NCC002-FD-016 CITRU\KART 20120127
        TempDimVal[1].SETRANGE("Dimension Code", AnalysisView."Dimension 1 Code");
        TempDimVal[2].SETRANGE("Dimension Code", AnalysisView."Dimension 2 Code");
        TempDimVal[3].SETRANGE("Dimension Code", AnalysisView."Dimension 3 Code");
        TempDimVal[4].SETRANGE("Dimension Code", AnalysisView."Dimension 4 Code");
        TempDimVal[5].SETRANGE("Dimension Code", AnalysisView."Dimension 5 Code");
        TempDimVal[6].SETRANGE("Dimension Code", AnalysisView."Dimension 6 Code");
        // MC IK 20120608 >>
        TempDimVal[7].SETRANGE("Dimension Code", AnalysisView."Dimension 7 Code");
        TempDimVal[8].SETRANGE("Dimension Code", AnalysisView."Dimension 8 Code");
        // MC IK 20120608 <<

        CASE CalculationMethod OF
         CalculationMethod::ByDimensions:
          BEGIN
            IF (AnalysisView."Dimension 1 Code" = '') OR TempDimVal[1].FINDFIRST THEN BEGIN
              FlagEnd[1] := FALSE;
              FlagNOT[1] := FALSE;
              REPEAT
                IF (AnalysisView."Dimension 2 Code" = '') OR TempDimVal[2].FINDFIRST THEN BEGIN
                   FlagEnd[2] := FALSE;
                   FlagNOT[2] := FALSE;
                   REPEAT
                    IF (AnalysisView."Dimension 3 Code" = '') OR TempDimVal[3].FINDFIRST THEN BEGIN
                      FlagEnd[3] := FALSE;
                      FlagNOT[3] := FALSE;
                      REPEAT
                        IF (AnalysisView."Dimension 4 Code" = '') OR TempDimVal[4].FINDFIRST THEN BEGIN
                          FlagEnd[4] := FALSE;
                          FlagNOT[4] := FALSE;
                            REPEAT
                              IF (AnalysisView."Dimension 5 Code" = '') OR TempDimVal[5].FINDFIRST THEN BEGIN
                                FlagEnd[5] := FALSE;
                                FlagNOT[5] := FALSE;
                                  REPEAT
                                    IF (AnalysisView."Dimension 6 Code" = '') OR TempDimVal[6].FINDFIRST THEN BEGIN
                                      FlagEnd[6] := FALSE;
                                      FlagNOT[6] := FALSE;
                                        REPEAT
                                          // MC IK 20120608 >>
                                          IF (AnalysisView."Dimension 7 Code" = '') OR TempDimVal[7].FINDFIRST THEN BEGIN
                                            FlagEnd[7] := FALSE;
                                            FlagNOT[7] := FALSE;
                                              REPEAT
                                                IF (AnalysisView."Dimension 8 Code" = '') OR TempDimVal[8].FINDFIRST THEN BEGIN
                                                  FlagEnd[8] := FALSE;
                                                  FlagNOT[8] := FALSE;
                                                    REPEAT
                                          // MC IK 20120608 <<
                                                      CalculateOneDimLevel(Rc, TempDimVal);
                                          // MC IK 20120608 >>
                                                      IF (AnalysisView."Dimension 8 Code" <> '') THEN
                                                        FlagEnd[8] := TempDimVal[8].NEXT = 0;
                                                    UNTIL (AnalysisView."Dimension 8 Code" = '') OR FlagEnd[8];
                                                END;
                                                IF (AnalysisView."Dimension 7 Code" <> '') THEN
                                                  FlagEnd[7] := TempDimVal[7].NEXT = 0;
                                              UNTIL (AnalysisView."Dimension 7 Code" = '') OR FlagEnd[7];
                                          END;
                                          // MC IK 20120608 <<
                                          IF (AnalysisView."Dimension 6 Code" <> '') THEN
                                            FlagEnd[6] := TempDimVal[6].NEXT = 0;
                                        UNTIL (AnalysisView."Dimension 6 Code" = '') OR FlagEnd[6];
                                    END;
                                    IF (AnalysisView."Dimension 5 Code" <> '') THEN
                                       FlagEnd[5] := TempDimVal[5].NEXT = 0;
                                  UNTIL (AnalysisView."Dimension 5 Code" = '') OR FlagEnd[5];
                               END;
                               IF (AnalysisView."Dimension 4 Code" <> '') THEN
                                  FlagEnd[4] := TempDimVal[4].NEXT = 0;
                            UNTIL (AnalysisView."Dimension 4 Code" = '') OR FlagEnd[4];
                         END;
                         IF (AnalysisView."Dimension 3 Code" <> '') THEN
                            FlagEnd[3] := TempDimVal[3].NEXT = 0;
                      UNTIL (AnalysisView."Dimension 3 Code" = '') OR FlagEnd[3];
                   END;
                 IF (AnalysisView."Dimension 2 Code" <> '') THEN
                    FlagEnd[2] := TempDimVal[2].NEXT = 0;
                  UNTIL (AnalysisView."Dimension 2 Code" = '') OR FlagEnd[2];
                END;
             IF (AnalysisView."Dimension 1 Code" <> '') THEN
                FlagEnd[1] := TempDimVal[1].NEXT = 0;
              UNTIL (AnalysisView."Dimension 1 Code" = '') OR FlagEnd[1];
            END;
          //By Dimensions Mehtod End;
          END;
         CalculationMethod::ByAnalysisView:
          BEGIN
           AnalysisViewEntryTemp.RESET;
           IF AnalysisViewEntryTemp.FINDSET THEN
               REPEAT
                TempDimVal[1]."Dimension Code":=AnalysisView."Dimension 1 Code";
                TempDimVal[1].Code:=AnalysisViewEntryTemp."Dimension 1 Value Code";
        //        TempDimVal[1].Name:=Text50000;
                TempDimVal[2]."Dimension Code":=AnalysisView."Dimension 2 Code";
                TempDimVal[2].Code:=AnalysisViewEntryTemp."Dimension 2 Value Code";
                TempDimVal[3]."Dimension Code":=AnalysisView."Dimension 3 Code";
                TempDimVal[3].Code:=AnalysisViewEntryTemp."Dimension 3 Value Code";
                TempDimVal[4]."Dimension Code":=AnalysisView."Dimension 4 Code";
                TempDimVal[4].Code:=AnalysisViewEntryTemp."Dimension 4 Value Code";
                TempDimVal[5]."Dimension Code":=AnalysisView."Dimension 5 Code";
                TempDimVal[5].Code:=AnalysisViewEntryTemp."Dimension 5 Value Code";
                TempDimVal[6]."Dimension Code":=AnalysisView."Dimension 6 Code";
                TempDimVal[6].Code:=AnalysisViewEntryTemp."Dimension 6 Value Code";
                // MC IK 20120608 >>
                TempDimVal[7]."Dimension Code":=AnalysisView."Dimension 7 Code";
                TempDimVal[7].Code:=AnalysisViewEntryTemp."Dimension 7 Value Code";
                TempDimVal[8]."Dimension Code":=AnalysisView."Dimension 8 Code";
                TempDimVal[8].Code:=AnalysisViewEntryTemp."Dimension 8 Value Code";
                // MC IK 20120608 <<
                CalculateOneDimLevel(Rc, TempDimVal);
               UNTIL AnalysisViewEntryTemp.NEXT =0;
           //By Analysis View Mehtod End;
          END;
         CalculationMethod::ByGLEntry:
          BEGIN
           //By GL entrys End;
          END;
        //Case End
        END;
        // SWC847 DD 04.06.16 >>
        PackEntries(Rc);
        // SWC847 DD 04.06.16 <<

        Window.CLOSE;

        Rc."Last Run Date" := TODAY;
        Rc."Last Run Time" := TIME;
        Rc."User ID" := USERID;
        */
    end;

    procedure CopyDocument(FromCalculationRecord: Record "Calculation Journal Line"; var ToCalculationRecord: Record "Calculation Journal Line")
    var
        CGenJnl: Record "Calculation Journal Line";
        CGenJnlLine: Record "Calculation Journal Line";
        CGenJnlOper: Record "Calc. Gen Journal Operand";
        CGenJnlOper1: Record "Calc. Gen Journal Operand";
        EnNoOper: Integer;
    begin

        ToCalculationRecord := FromCalculationRecord;
        ToCalculationRecord."Entry No." := 0;
        ToCalculationRecord."Last Run Date" := 0D;
        ToCalculationRecord."Last Run Time" := 0T;
        ToCalculationRecord."User ID" := '';

        CGenJnl.RESET;
        CGenJnl.SETRANGE(Month, ToCalculationRecord.Month);
        CGenJnl.SETRANGE(Year, ToCalculationRecord.Year);
        CGenJnl.SETRANGE("Journal Template Name", ToCalculationRecord."Journal Template Name");
        CGenJnl.SETRANGE("Journal Batch Name", ToCalculationRecord."Journal Batch Name");
        CGenJnl.SETCURRENTKEY(Year, Month, "Journal Template Name", "Journal Batch Name", "Document No.");
        IF CGenJnl.FIND('+') THEN ToCalculationRecord."Document No." := INCSTR(CGenJnl."Document No.");


        ToCalculationRecord.INSERT(TRUE);

        //Измерения
        //JnlLineDim.RESET;
        //JnlLineDim.SETRANGE("Table ID",DATABASE::"Calculation Journal Line");
        //JnlLineDim.SETRANGE("Journal Template Name",'');
        //JnlLineDim.SETRANGE("Journal Batch Name",'');
        //JnlLineDim.SETRANGE("Journal Line No.","Entry No.");
        //IF JnlLineDim.FIND('-') THEN BEGIN
        // JnlLineDim1.LOCKTABLE;
        //REPEAT
        //JnlLineDim1 := JnlLineDim;
        //JnlLineDim1."Journal Line No." := ToCalculationRecord."Entry No.";
        //nlLineDim1.INSERT;
        //UNTIL JnlLineDim.NEXT = 0;
        //END;

        CGenJnlOper1.LOCKTABLE;
        CGenJnlOper1.RESET;
        IF CGenJnlOper1.FIND('+') THEN
            EnNoOper := CGenJnlOper1."Entry No." + 1
        ELSE
            EnNoOper := 1;

        //Операнды
        CGenJnlOper.RESET;
        CGenJnlOper.SETCURRENTKEY("Calc. Gen. Jnl. Entry No.", "Type Operation", "Line No.");
        CGenJnlOper.SETRANGE("Calc. Gen. Jnl. Entry No.", FromCalculationRecord."Entry No.");
        IF CGenJnlOper.FIND('-') THEN
            REPEAT
                CGenJnlOper1 := CGenJnlOper;
                CGenJnlOper1."Entry No." := EnNoOper;
                CGenJnlOper1."Calc. Gen. Jnl. Entry No." := ToCalculationRecord."Entry No.";
                CGenJnlOper1.INSERT;
                EnNoOper += 1;
            UNTIL CGenJnlOper.NEXT = 0;
        //END;
    end;

    var
        myInt: Integer;
}