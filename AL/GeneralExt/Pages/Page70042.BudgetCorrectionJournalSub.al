page 70042 "Budget Correction Journal Sub"
{
    InsertAllowed = false;
    DeleteAllowed = true;
    SourceTable = "Budget Correction Journal";
    SourceTableView = WHERE(Posted = CONST(true));
    PageType = ListPart;
    Caption = 'Posted';

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;

                }

                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;

                }

                field("Doc No"; Rec."Doc No")
                {
                    ApplicationArea = All;

                }

                field("G/L Account Totaling"; Rec."G/L Account Totaling")
                {
                    ApplicationArea = All;

                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }

                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;

                }

                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: text): boolean
                    begin
                        IF VendorAgreement.GET("Vendor No.", "Agreement No.") THEN
                            PAGE.RUN(14902, VendorAgreement);
                    end;


                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;

                }

                field("Real Contragent No."; Rec."Real Contragent No.")
                {
                    Visible = false;
                    ApplicationArea = All;

                }

                field("Dimension Totaling 1"; Rec."Dimension Totaling 1")
                {
                    ApplicationArea = All;

                }

                field("Dimension Totaling 2"; Rec."Dimension Totaling 2")
                {
                    ApplicationArea = All;

                }

                field("Cost Type"; Rec."Cost Type")
                {
                    ApplicationArea = All;

                }

                field(Date; Rec.Date)
                {
                    ApplicationArea = All;

                }

                field("Original Date"; Rec."Original Date")
                {
                    ApplicationArea = All;

                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                }

                field(Advances; Rec.Advances)
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                // field("Apply Amount"; Rec."Apply Amount")
                // {
                //     DrillDown = No;
                //     ApplicationArea = All;

                // }

                // field("Diff Amount"; Rec."Diff Amount")
                // {
                //     ApplicationArea = All;

                // }

                // field("Budget Amount"; Rec."Budget Amount")
                // {
                //     Editable = false;
                //     ApplicationArea = All;
                //     trigger OnLookup(var Text: text): boolean
                //     begin
                //         /*PBE.RESET;
                //         PBE.SETRANGE("Building Turn All",ID);
                //         IF PBE.FINDFIRST THEN;

                //         PAGE.RUN(70141,PBE);
                //          */
                //     end;


                // }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;

                }

                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;

                }

                // field("Exist Linck Entry"; Rec."Exist Linck Entry")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }

                field("User id"; Rec."User id")
                {
                    Visible = true;
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Creation Date"; Rec."Creation Date")
                {
                    Visible = true;
                    Editable = false;
                    ApplicationArea = All;

                }



            }
        }
    }


    actions
    {
        area(Processing)
        {
            group("Command Buttons")
            {
                action(Control12370031)
                {
                    Caption = 'Test';
                    trigger OnAction()
                    begin
                        IF Rec.FIND('-') THEN
                            REPEAT

                                ProjectsCostControlEntry.SETRANGE(ID, Rec.ID);

                                /* t17.CHANGECOMPANY("Company Name");
                                 t17.SETRANGE(ID,ID);
                                 IF NOT t17.FINDFIRST THEN
                                   MARK:=TRUE;

                                 IF t17.COUNT>1 THEN  MARK:=TRUE;  */
                                IF NOT ProjectsCostControlEntry.FINDFIRST THEN Rec.MARK := TRUE;
                            UNTIL Rec.NEXT = 0;
                        Rec.MARKEDONLY := TRUE;
                    end;


                }

                action(Control12370032)
                {
                    Caption = 'Fill RealData';
                    trigger OnAction()
                    var
                        BC: record "Budget Correction";
                        GLE: record "G/L Entry";
                        Agr1: record "Vendor Agreement";
                        Agr: record "Vendor Agreement";
                    begin
                        IF Rec.FINDSET THEN BEGIN
                            REPEAT
                                Rec."Real Agreement No." := '';
                                Rec."Real Contragent Name" := '';
                                Rec."Real Contragent No." := '';
                                Rec."Real External Agreement No." := '';
                                Rec.MODIFY;

                                IF BC.GET(Code) THEN BEGIN
                                    // IF NOT BC.Allocation THEN BEGIN
                                    IF BC."Company Name" <> '' THEN BEGIN
                                        GLE.CHANGECOMPANY(BC."Company Name");
                                    END
                                    ELSE BEGIN
                                        GLE.CHANGECOMPANY(COMPANYNAME);
                                    END;
                                    // GLE.SETCURRENTKEY(ID);
                                    // GLE.SETRANGE(ID,ID);
                                    GLE.SETRANGE("Document No.", Rec."Doc No");
                                    GLE.FINDFIRST;


                                    // IF BC."Agreement From Current Company" THEN
                                    // BEGIN
                                    Rec."Real Agreement No." := GLE."Agreement No.";
                                    //   IF "Real Agreement No."='' THEN
                                    //     "Real Agreement No.":=GetAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    // END
                                    // ELSE
                                    // BEGIN
                                    //   "Real Agreement No.":=GetAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //   IF "Real Agreement No."='' THEN
                                    //     "Real Agreement No.":=GLE."Agreement No.";
                                    // END;

                                    // IF NOT BC."Agreement From Current Company" THEN
                                    // BEGIN
                                    //  //договор из текущей компании
                                    //  Rec."Real Contragent Name":=GetVendorNameAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //  Rec."Real Contragent No.":=GetVendorAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //  Rec."Real External Agreement No.":=GetExtAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //  IF Rec."Real Contragent No."='' THEN
                                    //  BEGIN
                                    //    Rec."Real Contragent Name":=GetVendorNameAgreement(GLE."Document No.",GLE.Amount,BC."Company Name");
                                    //    Rec."Real Contragent No.":=GetVendorAgreement(GLE."Document No.",GLE.Amount,BC."Company Name");
                                    //    Rec."Real External Agreement No.":=GetExtAgreement(GLE."Document No.",GLE.Amount,BC."Company Name");
                                    //  END;
                                    // END
                                    // ELSE
                                    // BEGIN
                                    //  //договор из другой компании
                                    Rec."Real Contragent Name" := GetVendorNameAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                    Rec."Real Contragent No." := GetVendorAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                    Rec."Real External Agreement No." := GetExtAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                    //  IF "Real Contragent No."='' THEN
                                    //  BEGIN
                                    //    "Real Contragent Name":=GetVendorNameAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //    "Real Contragent No.":=GetVendorAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //    "Real External Agreement No.":=GetExtAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                    //  END;
                                    // END;

                                    IF NOT Agr1.GET(Rec."Real Contragent No.", Rec."Real Agreement No.") THEN
                                        Rec."Real Agreement No." := '';
                                    // ELSE
                                    // BEGIN
                                    //   IF BC."Agreement Company Name"<>COMPANYNAME THEN
                                    //     IF NOT BC."Agreement From Current Company" THEN
                                    //       "Real Agreement No.":='';

                                    // END;
                                    // IF ("Real Agreement No."='') AND (NOT BC.Allocation) THEN
                                    // BEGIN
                                    //   "Real Agreement No.":=BC."Virtual Agreement";
                                    //   IF "Real Agreement No."<>'' THEN
                                    //   BEGIN
                                    //     Agr.SETRANGE("No.","Real Agreement No.");
                                    //     IF Agr.FINDFIRST THEN
                                    //       "Real Contragent No.":=Agr."Vendor No.";
                                    //   END;
                                    // END;

                                    Rec.MODIFY;
                                    // END;
                                END;
                            UNTIL Rec.NEXT = 0;
                        END;
                    end;


                }

                action(Control12370033)
                {
                    Caption = 'Test RealData';
                    trigger OnAction()
                    var
                        BC: record "Budget Correction";
                        GLE: record "G/L Entry";
                        Agr1: record "Vendor Agreement";
                        Agr: record "Vendor Agreement";
                    begin
                        IF Rec.FINDSET THEN BEGIN
                            REPEAT
                                IF Rec."Vendor No." <> Rec."Real Contragent No." THEN Rec.MARK := TRUE;
                            UNTIL Rec.NEXT = 0;
                        END;
                        Rec.MARKEDONLY := TRUE;
                    end;


                }

                action(Control12370034)
                {
                    Caption = 'Sinch RealData';
                    trigger OnAction()
                    var
                        BC: record "Budget Correction";
                        GLE: record "G/L Entry";
                        Agr1: record "Vendor Agreement";
                        Agr: record "Vendor Agreement";
                        PPCE: record "Projects Cost Control Entry";
                    begin
                        IF Rec.FINDSET THEN BEGIN
                            REPEAT
                                IF Rec."Real Contragent No." <> '' THEN BEGIN
                                    PPCE.SETRANGE(ID, Rec.ID);
                                    PPCE.SETRANGE("Doc No.", Rec."Doc No");
                                    IF PPCE.FINDFIRST THEN BEGIN
                                        IF PPCE.COUNT > 1 THEN ERROR('1');
                                        PPCE."Contragent No." := Rec."Real Contragent No.";
                                        PPCE."Agreement No." := Rec."Real Agreement No.";
                                        PPCE."Contragent Name" := Rec."Real Contragent Name";
                                        PPCE."External Agreement No." := Rec."Real External Agreement No.";
                                        PPCE.MODIFY;
                                        Rec."Agreement No." := Rec."Real Agreement No.";
                                        Rec."Vendor No." := Rec."Real Contragent No.";
                                        Rec."External Agreement No." := Rec."Real External Agreement No.";
                                        Rec."Vendor Name" := Rec."Real Contragent Name";
                                        Rec.MODIFY;
                                    END;
                                END;
                            UNTIL Rec.NEXT = 0;
                        END;
                        Rec.MARKEDONLY := TRUE;
                    end;


                }


            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        // Rec."Budget Amount":=GetBudgetAmount;
    end;

    trigger OnOpenPage()
    begin


    end;



    var
        PBE: record "Projects Budget Entry";
        VendorAgreement: record "Vendor Agreement";
        t17: record "G/L Entry";
        ProjectsCostControlEntry: record "Projects Cost Control Entry";


    procedure GetBudgetAmount(): decimal
    var
        LocPBE: record "Projects Budget Entry";
        Amt: decimal;
    begin
        /*Amt:=0;
        LocPBE.RESET;
        LocPBE.SETRANGE("Building Turn All",ID);
        IF LocPBE.FIND('-') THEN
        REPEAT
          LocPBE.CALCFIELDS("Without VAT");
          Amt+=LocPBE."Without VAT";
        UNTIL LocPBE.NEXT=0;
        
        EXIT(Amt);
             */
    end;

    procedure UpdateForm()
    begin
        CurrPage.UPDATE(FALSE);
    end;

    procedure GetEntry() Ret: boolean
    var
        ProjectsCostControlEntry: record "Projects Cost Control Entry";
    begin
        ProjectsCostControlEntry.SETCURRENTKEY(ID);
        ProjectsCostControlEntry.SETRANGE(ID, ID);
        IF ProjectsCostControlEntry.FINDFIRST THEN EXIT(TRUE);
    end;

    procedure GetExtAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: text[30]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
    begin
        lrGE.RESET;

        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
        END;
        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);

        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN
                Ret := lrVA."External Agreement No.";


        END;
    end;

    procedure GetVendorAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: code[20]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
        lrVendor: record Vendor;
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
            lrVendor.CHANGECOMPANY(CompanyName);
        END;

        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);


        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN BEGIN
                IF lrVendor.GET(lrVA."Vendor No.") THEN
                    Ret := lrVendor."No.";

            END;
        END;
    end;

    procedure GetVendorNameAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: text[250]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
        lrVendor: record Vendor;
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
            lrVendor.CHANGECOMPANY(CompanyName);
        END;

        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);


        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN BEGIN
                IF lrVendor.GET(lrVA."Vendor No.") THEN
                    Ret := lrVendor.Name;
            END;
        END;
    end;

    procedure GetAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: code[20]
    var
        lrGE: record "G/L Entry";
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN
            lrGE.CHANGECOMPANY(CompanyName);
        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);

        IF lrGE.FINDFIRST THEN
            Ret := lrGE."Agreement No.";
    end;


}

