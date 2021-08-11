page 70213 "Projects CC Entry Constr 2"
{

    ApplicationArea = Basic, Suite;
    Caption = 'Projects CC Entry Constr 2';
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Projects Cost Control Entry";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contragent Name"; Rec."Contragent Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Doc No."; Rec."Doc No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Without VAT"; Rec."Without VAT")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Including VAT 2"; Rec."Amount Including VAT 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Amount 2"; Rec."VAT Amount 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cost Type"; Rec."Cost Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Agrrement No."; Rec."Agreement No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("External Agreement No."; Rec."External Agreement No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(ID; Rec.ID)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Building Turn"; Rec."Building Turn")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Turn Code"; Rec."Project Turn Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Create User"; Rec."Create User")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Storno"; Rec."Project Storno")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Analysis Type"; Rec."Analysis Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reserve; Rec.Reserve)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Original Date"; Rec."Original Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Original Company"; Rec."Original Company")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Original Ammount"; Rec."Original Ammount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Changed; Rec.Changed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Line No."; Rec."Estimate Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Quantity"; Rec."Estimate Quantity")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Unit Price"; Rec."Estimate Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Unit of Measure"; Rec."Estimate Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Line ID"; Rec."Estimate Line ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Subproject Code"; Rec."Estimate Subproject Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Reverse)
            {
                Caption = 'Reverse';
                trigger OnAction()
                var
                    PCCE: record "Projects Cost Control Entry";
                    PCCE2: record "Projects Cost Control Entry";
                    Wnd: dialog;
                    EnterDate: date;
                begin
                    // SWC983 DD 19.01.17 >>
                    //IF NOT CONFIRM('Сторнировать выделенные строки?') THEN
                    //  EXIT;
                    CurrPage.SETSELECTIONFILTER(PCCE);
                    PCCE.FINDSET;
                    EnterDate := PCCE.Date;
                    // Wnd.OPEN('Введите Дату Учета (Enter): #1#######');
                    // Wnd.INPUT(1,EnterDate);
                    IF EnterDate = 0D THEN
                        EXIT;
                    PCCE.SETRANGE("Project Storno", FALSE);
                    IF PCCE.FINDSET THEN
                        REPEAT
                            PCCE."Project Storno" := TRUE;
                            PCCE.Changed := TRUE;
                            PCCE.MODIFY;
                            PCCE2 := PCCE;
                            PCCE2."Entry No." := PCCE2.GetNextEntryNo;
                            PCCE2."Create User" := USERID;
                            PCCE2."Create Date" := TODAY;
                            PCCE2."Create Time" := TIME;
                            PCCE2."Without VAT" := -PCCE2."Without VAT";
                            //   PCCE2.VAT := -PCCE2.VAT;
                            PCCE2.Amount := -PCCE2.Amount;
                            PCCE2."Amount (LCY)" := -PCCE2."Amount (LCY)";
                            //   PCCE2."Temp Amount" := -PCCE2."Temp Amount";
                            PCCE2."Original Ammount" := -PCCE2."Original Ammount";
                            PCCE2.Date := EnterDate;
                            PCCE2.Changed := FALSE;
                            //NC-47122 DP >>
                            PCCE2."Amount 2" := -PCCE2."Amount 2";
                            PCCE2."Amount Including VAT 2" := -PCCE2."Amount Including VAT 2";
                            PCCE2."VAT Amount 2" := -PCCE2."VAT Amount 2";
                            //NC-47122 DP <<
                            PCCE2.INSERT;
                        UNTIL PCCE.NEXT = 0;
                    CurrPage.UPDATE(FALSE);
                    // SWC983 DD 19.01.17 <<
                end;
            }
            action(ManualInput)
            {
                Caption = 'Manual Input';
                trigger OnAction()
                var
                    lrProjectsCostControlEntry: record "Projects Cost Control Entry";
                begin
                    //FILTERGROUP:=2;
                    lrProjectsCostControlEntry.RESET;
                    lrProjectsCostControlEntry.INIT;
                    lrProjectsCostControlEntry.COPY(Rec);
                    lrProjectsCostControlEntry."Entry No." := 0;
                    lrProjectsCostControlEntry."Description 2" := '';
                    lrProjectsCostControlEntry.Amount := 0;
                    lrProjectsCostControlEntry.Date := 0D;
                    lrProjectsCostControlEntry."Original Date" := 0D;
                    lrProjectsCostControlEntry."Without VAT" := 0;
                    lrProjectsCostControlEntry."Cost Type" := '';
                    lrProjectsCostControlEntry."Contragent No." := '';
                    lrProjectsCostControlEntry."Agreement No." := '';
                    lrProjectsCostControlEntry.ID := 0;
                    // lrProjectsCostControlEntry."IFRS Account No." := '';
                    lrProjectsCostControlEntry."Original Ammount" := 0;
                    lrProjectsCostControlEntry."Project Code" := GETFILTER("Project Code");
                    EVALUATE(lrProjectsCostControlEntry."Line No.", GETFILTER("Line No."));
                    // grPrjStrLine.SETFILTER("Project Code", GETFILTER("Project Code"));
                    // grPrjStrLine.SETFILTER("Line No.", GETFILTER("Line No."));
                    // IF grPrjStrLine.FINDFIRST THEN BEGIN

                    //     lrProjectsCostControlEntry.Description := grPrjStrLine.Description;
                    //     lrProjectsCostControlEntry.Code := grPrjStrLine.Code;
                    lrProjectsCostControlEntry."Analysis Type" := "Analysis Type"::Actuals;
                    // END;
                    //FILTERGROUP:=0;
                    lrProjectsCostControlEntry."Doc No." := 'MANUAL';
                    lrProjectsCostControlEntry."User Created" := TRUE;
                    lrProjectsCostControlEntry."Create User" := USERID;
                    lrProjectsCostControlEntry."Create Date" := TODAY;
                    lrProjectsCostControlEntry."Create Time" := TIME;
                    lrProjectsCostControlEntry.INSERT(TRUE);
                    CurrPage.UPDATE;
                end;


            }
            action(ChangeRec)
            {
                Caption = 'Change';
                trigger OnAction()
                begin
                    grPCCE.DELETEALL;
                    grPCCE.TRANSFERFIELDS(Rec);
                    grPCCE."Building Turn" := "Project Turn Code";
                    grPCCE."Cost Code" := Code;
                    grPCCE."New Lines" := "Line No.";
                    grPCCE.INSERT;
                    PAGE.RUN(70217, grPCCE);
                end;


            }
            action(ChangeLog)
            {
                Caption = 'Change Log';
                trigger OnAction()
                var
                    CLE: record "Change Log Entry";
                begin
                    // CLE.SETCURRENTKEY("Table No.","Primary Key Field 5 Value");
                    CLE.SETRANGE("Table No.", Database::"Projects Cost Control Entry");
                    CLE.SETRANGE("Primary Key Field 1 Value", "Project Code");
                    // CLE.SETRANGE("Primary Key Field 5 Value",FORMAT("Entry No."));
                    IF CLE.FINDFIRST THEN
                        PAGE.RUNMODAL(0, CLE);
                end;


            }
        }
    }
    var
        grPCCE: Record "Projects Cost Control Entry" temporary;

}
