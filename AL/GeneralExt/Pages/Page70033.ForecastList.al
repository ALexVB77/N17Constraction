page 70033 "Forecast List"
{
    Editable = false;
    DeleteAllowed = false;
    SourceTable = "Projects Budget Entry";
    PageType = List;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    Caption = 'Forecast List';


    layout
    {
        area(content)
        {
            group("Payment Amount incl. VAT")
            {
                Editable = false;
                field(vAmount; vAmount)
                {
                    Editable = false;
                    ApplicationArea = All;
                    Visible = false;
                }



            }
            repeater(Repeater12370003)
            {
                Editable = false;
                field(Close; Rec.Close)
                {
                    Visible = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }

                // field("Applied-to Entry No."; Rec."Applied-to Entry No.")
                // {
                //     Visible = false;
                //     Editable = false;
                //     ApplicationArea = All;

                // }   

                field(Date; Rec.Date)
                {
                    ApplicationArea = All;

                }
                field("Without VAT (LCY)"; Rec."Without VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Date Plan"; Rec."Date Plan")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    var
                        LRpl: record "Purchase Line";
                        LRph: record "Purchase Header";
                    begin
                        IF Rec.Close THEN BEGIN
                            LRpl.SETCURRENTKEY("Forecast Entry");
                            LRpl.SETRANGE("Forecast Entry", Rec."Entry No.");
                            IF LRpl.FINDFIRST THEN BEGIN
                                LRph.SETRANGE("Document Type", LRpl."Document Type");
                                LRph.SETRANGE("No.", LRpl."Document No.");
                                IF LRph.FINDFIRST THEN BEGIN
                                    PAGE.RUN(70000, LRph);

                                END;
                            END;
                        END;
                    end;


                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;

                }

                // field(Amount; Rec.Amount)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Сумма';

                // }   

                // field("Write Off Amount "; Rec."Write Off Amount")
                // {
                //     BlankZero = true;
                //     ApplicationArea = All;
                //     trigger OnValidate()
                //     var 
                //         WriteOffAmount: decimal;
                //         PBE: record "Projects Budget Entry";
                //         Vend: record Vendor;
                //     begin
                //         WriteOffAmountOnAfterValidate; //navnav;


                //         //NC 27251/29129 HR beg
                //         IF NOT IsProductionProject THEN BEGIN
                //           //SWC030 AKA 160514 >>
                //           IF "Agreement No." <> '' THEN
                //           BEGIN
                //              "Write Off Amount" := 0;
                //             MESSAGE('В этой строке нельзя указать Сумму списания');
                //           END;
                //           //SWC030 AKA 160514 <<
                //         END;
                //         //NC 29129 HR end

                //         // SWC1004 DD 18.02.17 >>
                //         IF (gPH."Agreement No." <> '') AND ("Write Off Amount" > 0) THEN BEGIN
                //           WriteOffAmount := "Write Off Amount";
                //           PBE.SETCURRENTKEY("Work Version","Agreement No.","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
                //           IF Vend.GET(gPH."Buy-from Vendor No.") AND (Vend."Vendor Type" = Vend."Vendor Type"::"Tax Authority") THEN
                //             PBE.SETFILTER("Contragent No.",'%1|%2',gPH."Buy-from Vendor No.",'')
                //           ELSE
                //             PBE.SETRANGE("Contragent No.",gPH."Buy-from Vendor No.");
                //           PBE.SETRANGE("Agreement No.",'');
                //           PBE.SETRANGE("Shortcut Dimension 1 Code","Shortcut Dimension 1 Code");
                //           PBE.SETRANGE("Shortcut Dimension 2 Code","Shortcut Dimension 2 Code");
                //           PBE.SETRANGE(Close,FALSE);
                //           PBE.SETRANGE(Reserve,FALSE);
                //           PBE.SETFILTER("Without VAT",'<>%1',0);
                //           PBE.SETFILTER("Write Off Amount",'<>0');
                //           PBE.SETFILTER("Entry No.",'<>%1',"Entry No.");
                //           IF PBE.FINDSET THEN
                //           REPEAT
                //             WriteOffAmount += PBE."Write Off Amount";
                //           UNTIL PBE.NEXT = 0;
                //           CheckCF(gPH."Buy-from Vendor No.",gPH."Agreement No.",WriteOffAmount);
                //         END;
                //         // SWC1004 DD 18.02.17 <<
                //     end;


                // }   


                field("Transaction Type"; Rec."Transaction Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = All;

                }

                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;

                }

                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;

                }

                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;

                }

                field("Payment Doc. No."; Rec."Payment Doc. No.")
                {
                    Editable = false;
                    ApplicationArea = All;

                }



            }
        }
    }


    actions
    {
        area(navigation)
        {
        }
    }


    // trigger OnQueryClosePage(CloseAction: Action): Boolean
    // var
    //     rAmount: decimal;
    // begin
    //     //SWC030 AKA 190514 >>
    //     rAmount := 0;
    //     IF OkButton THEN BEGIN
    //         IF WriteOfAmount AND (Rec."Write Off Amount" <> 0) AND (AgreementNo <> '') THEN BEGIN
    //             Rec."Without VAT" := Rec."Without VAT" - Rec."Write Off Amount";
    //             rAmount := Rec.Amount - Rec."Write Off Amount";
    //             Rec.VALIDATE(Amount, rAmount);
    //         END;
    //     END;
    //     //SWC030 AKA 190514 <<
    // end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     Rec.CALCFIELDS("Payment Doc. No.");
    //     // IF ("Without VAT" < vAmount) OR (("Payment Doc. No." <> '') AND ("Payment Doc. No." <> gPH."Document No."))
    //     //  THEN
    //     //     CurrPage.Ok.VISIBLE := FALSE ELSE
    //     //     CurrPage.Ok.VISIBLE := TRUE;

    //     // SWC962 DD 05.12.16 >>
    //     // SetAgrNo2(gPH."Buy-from Vendor No.", gPH."Agreement No.");
    //     // SWC962 DD 05.12.16 <<
    // end;

    // trigger OnDeleteRecord(): boolean
    // begin
    //     US.GET(USERID);
    //     IF NOT US."Administrator PRJ" THEN ERROR(Text0011);
    // end;

    // trigger OnOpenPage()
    // begin
    // AgreementNoOnFormat; //navnav;

    // ContragentNoOnFormat; //navnav;

    // AmountOnFormat; //navnav;

    // Description2OnFormat; //navnav;

    // DescriptionOnFormat; //navnav;

    // DateOnFormat; //navnav;

    // EntryNoOnFormat; //navnav;

    // ChangeFormParameters(); //SWC030 AKA 160514
    // end;



    var
        gPH: record "Purchase Line";
        ProjectsBudgetEntry: record "Projects Budget Entry";
        gcERPC: codeunit "ERPC Funtions";
        vAmount: decimal;
        WriteOfAmount: boolean;

        ProductionMode: boolean;
        OkButton: boolean;
        US: record "User Setup";
        AgreementNo: code[20];
    // Text001: Label 'Превышена сумма остатка строки!';
    // Text0011: Label 'Нельзя удалять операции!';



    procedure SetRecordFl(pPH: record "Purchase Line")
    begin
        gPH := pPH;
        // vAmount := gcERPC.GetLineAmount(gPH);
    end;

    procedure SetParam(Param: boolean; AgreemParam: code[20])
    begin
        //SWC030 AKA 160514
        WriteOfAmount := Param;
        AgreementNo := AgreemParam;
    end;

    procedure SetParamProductionMode(NewWritingOffMode: boolean; NewProductionMode: boolean; NewAgrCode: code[20])
    begin
        //NC 27251 HR beg
        WriteOfAmount := NewWritingOffMode;
        ProductionMode := NewProductionMode;
        AgreementNo := NewAgrCode;
        //NC 27251 HR end
    end;

    // procedure ChangeFormParameters()
    // begin
    //     //SWC030 AKA 160514
    //     IF WriteOfAmount THEN BEGIN
    //         CurrPage."Write Off Amount".VISIBLE := TRUE;
    //         CurrPage.EDITABLE := TRUE;
    //         CurrPage.Close.EDITABLE := FALSE;
    //         CurrPage."Entry No.".EDITABLE := FALSE;
    //         CurrPage.Date.EDITABLE := FALSE;
    //         CurrPage.Description.EDITABLE := FALSE;
    //         CurrPage."Description 2".EDITABLE := FALSE;
    //         //NC 27251 HR beg
    //         //CurrForm.Amount.EDITABLE := FALSE;
    //         IF ProductionMode THEN
    //             CurrPage.Amount.EDITABLE := TRUE
    //         ELSE
    //             CurrPage.Amount.EDITABLE := FALSE;
    //         //NC 27251 HR end
    //         CurrPage."Write Off Amount".EDITABLE := TRUE;
    //         CurrPage."Transaction Type".EDITABLE := FALSE;
    //         CurrPage."Contragent No.".EDITABLE := FALSE;
    //         CurrPage."Agreement No.".EDITABLE := FALSE;
    //         CurrPage."Shortcut Dimension 1 Code".EDITABLE := FALSE;
    //         CurrPage."Shortcut Dimension 2 Code".EDITABLE := FALSE;
    //         CurrPage."Payment Doc. No.".EDITABLE := FALSE;
    //     END ELSE BEGIN
    //         CurrPage.EDITABLE := FALSE;
    //         CurrPage."Write Off Amount".VISIBLE := FALSE;
    //     END;
    // end;

    // local procedure EntryNoOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage."Entry No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Entry No.".UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage."Entry No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Entry No.".UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;

    // local procedure DateOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage.Date.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Date.UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage.Date.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Date.UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;

    // local procedure DescriptionOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage.Description.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Description.UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage.Description.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Description.UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;

    // local procedure Description2OnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage."Description 2".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Description 2".UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage."Description 2".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Description 2".UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;

    // local procedure AmountOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage.Amount.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Amount.UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage.Amount.UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage.Amount.UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514

    //     IF "Without VAT" < vAmount THEN CurrPage.Amount.UPDATEFORECOLOR := 255;
    // end;

    // local procedure WriteOffAmountOnAfterValidate()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF Amount < "Write Off Amount" THEN BEGIN
    //         "Write Off Amount" := xRec."Write Off Amount";
    //         ERROR(Text001);
    //     END;
    //     //SWC030 AKA 160514 <<
    // end;

    // local procedure ContragentNoOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage."Contragent No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Contragent No.".UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage."Contragent No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Contragent No.".UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;

    // local procedure AgreementNoOnFormat()
    // begin
    //     //SWC030 AKA 160514 >>
    //     IF WriteOfAmount THEN BEGIN
    //         IF "Agreement No." = '' THEN CurrPage."Agreement No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Agreement No.".UPDATEFORECOLOR := 32768;
    //     END ELSE BEGIN
    //         //SWC030 AKA 160514 <<
    //         IF "Contragent No." = '' THEN CurrPage."Agreement No.".UPDATEFORECOLOR := 16711680;
    //         IF Close THEN CurrPage."Agreement No.".UPDATEFORECOLOR := 32768;
    //     END; //SWC030 AKA 160514
    // end;


}