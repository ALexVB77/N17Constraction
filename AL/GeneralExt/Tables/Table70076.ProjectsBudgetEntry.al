table 70076 "Projects Budget Entry"
{
    Caption = 'Projects Budget Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            // TableRelation = "Building project";
        }
        field(3; "Analysis Type"; Option)
        {
            Caption = 'Analysis Type';
            OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
            OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
        }
        field(4; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'OwnWorks,Subcontract,Materials,Income';
            OptionMembers = OwnWorks,Subcontract,Materials,Income;
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
            NotBlank = true;
        }
        field(8; "Description 2"; Text[250])
        {
            Caption = 'Description 2';
        }
        field(9; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(10; Curency; Code[20])
        {
            Caption = 'Currency';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if Curency <> '' then
                    UpdateCurrencyFactor
                else begin
                    "Currency Factor" := 0;
                    "Currency Rate" := 0;
                end;

                ExchangeFCYtoLCY;
            end;
        }
        field(11; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(13; Date; Date)
        {
            Caption = 'Date';

            trigger OnValidate()
            begin
                if Curency <> '' then
                    UpdateCurrencyFactor
                else
                    "Currency Factor" := 0;
                ExchangeFCYtoLCY;
            end;
        }
        field(14; "Transaction Type"; Code[20])
        {
            Caption = 'Transaction Type';
            InitValue = 'OUT PURCH';
            TableRelation = "Cash Flow Transaction Type";
        }
        field(20; "Create User"; code[65])
        {
            Caption = 'Create User';
        }
        field(21; "Create Date"; Date)
        {
            Caption = 'Create Date';
        }
        field(22; "Create Time"; Time)
        {
            Caption = 'Create Time';
        }
        field(23; "Parent Entry"; Integer)
        {
            Caption = 'Parent Entry';
        }
        field(24; "Project Turn Code"; Code[20])
        {
            Caption = 'Project Turn Code';
            // TableRelation = "Building Turn";
        }
        field(29; Code; Code[20])
        {
            Caption = 'Code';
            Description = 'NC 50085 PA';
        }
        field(31; "Contragent No."; Code[20])
        {
            Caption = 'Contragent No.';
            TableRelation = if ("Contragent Type" = const(Vendor)) Vendor else
            if ("Contragent Type" = const(Customer)) Customer;
            trigger OnValidate()
            var
                lVend: Record Vendor;
                lCust: Record Customer;
            begin
                case Rec."Contragent Type" of
                    Rec."Contragent Type"::Customer:
                        begin
                            if lCust.Get(Rec."Contragent No.") then
                                "Contragent Name" := lCust.Name;
                        end;
                    Rec."Contragent Type"::Vendor:
                        begin
                            if lVend.Get(Rec."Contragent No.") then
                                "Contragent Name" := lVend.Name;

                        end;
                end;
            end;
        }
        field(32; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = if ("Contragent Type" = const(Vendor)) "Vendor Agreement"."No." where("Vendor No." = field("Contragent No."), Active = const(true)) else
            if ("Contragent Type" = const(Customer)) "Customer Agreement"."No." where("Customer No." = field("Contragent No."));
        }
        field(34; "Without VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            NotBlank = true;

            trigger OnValidate()
            begin
                Amount := "Without VAT";
                ExchangeFCYtoLCY;

                if "Currency Factor" <> 0 then
                    "Without VAT (LCY)" := "Without VAT" * (1 / "Currency Factor")
                else
                    "Without VAT (LCY)" := "Without VAT"
            end;
        }
        field(35; "Including VAT"; Boolean)
        {
            Caption = 'Including VAT';
            Editable = false;
        }
        field(36; "Contragent Name"; Text[250])
        {
            Caption = 'Contragent Name';
            Description = 'NC 50085 PA';
        }
        field(37; "External Agreement No."; Text[30])
        {
            Caption = 'Contragent Name';
            Description = 'NC 50085 PA';
        }
        field(40; "Contragent Type"; Option)
        {
            Caption = 'Contragent Type';
            OptionMembers = "Vendor","Customer";
            OptionCaption = 'Vendor,Customer';
        }
        field(41; "Temp Line No."; Integer)
        {
            Caption = 'Temp Line No.';
        }
        field(44; Close; Boolean)
        {
            Caption = 'Close';

            trigger OnValidate()
            begin
                lrProjectsBudgetEntryLink.SETRANGE("Main Entry No.", "Entry No.");
                lrProjectsBudgetEntryLink.SETRANGE("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.SETRANGE("Analysis Type", "Analysis Type");
                lrProjectsBudgetEntryLink.SETRANGE("Version Code", "Version Code");
                if lrProjectsBudgetEntryLink.FINDFIRST then begin
                    repeat
                        lrProjectsBudgetEntryLink.Close := Close;
                        lrProjectsBudgetEntryLink.Modify();
                    until lrProjectsBudgetEntryLink.Next() = 0;
                end;
            end;
        }
        field(45; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(46; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            trigger OnValidate()
            var
                lDimVal: Record "Dimension Value";
            begin
                lDimVal.Reset();
                lDimVal.SetRange("Global Dimension No.", 2);
                lDimVal.SetRange(Code, Rec."Shortcut Dimension 2 Code");
                if lDimVal.FindFirst() then
                    Description := lDimVal.Name;
            end;
        }
        field(47; "Building Turn"; Code[20])
        {
            Caption = 'Stage';
            NotBlank = true;
            // TableRelation = "Building Turn";

            trigger OnLookup()
            begin
                if ("Agreement No." <> '') and ("Without VAT" <> 0) then exit;
                gvBuildingTurn.Reset();
                if "Project Code" <> '' then
                    gvBuildingTurn.SETRANGE("Building project Code", "Project Code");
            end;

            trigger OnValidate()
            begin
                "Building Turn All" := "Building Turn";
                "Project Turn Code" := "Building Turn";

                if "Building Turn" = '' then begin
                    VALIDATE("Shortcut Dimension 1 Code", '');
                    "Project Code" := '';
                    "Version Code" := '';
                end else begin
                    gvBuildingTurn.GET("Building Turn");
                    VALIDATE("Shortcut Dimension 1 Code", gvBuildingTurn."Turn Dimension Code");
                    "Project Code" := gvBuildingTurn."Building project Code";
                    if "Version Code" = '' then
                        "Version Code" := GetDefVersion1("Project Code");
                end;
            end;
        }
        field(48; "Cost Code"; Code[20])
        {
            Caption = 'Budget Item';
            NotBlank = true;

            trigger OnLookup()
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
            begin
                if ("Agreement No." <> '') and ("Without VAT" <> 0) and (not IsProductionProject) then exit;

                grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                grProjectsStructureLines1.SetRange(Version, "Version Code");
                grProjectsStructureLines1.SetRange("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                if grProjectsStructureLines1.FindFirst() then begin
                    if "New Lines" = 0 then begin
                        if grProjectsStructureLines1.Get("Project Code", "Analysis Type", "Version Code", "Line No.") then;
                    end else
                        if grProjectsStructureLines1.Get("Project Code", "Analysis Type", "Version Code", "New Lines") then;

                    if Page.RunModal(Page::"Projects Article List", grProjectsStructureLines1) = Action::LookupOK then begin
                        "Cost Code" := grProjectsStructureLines1.Code;
                        ProjectsLineDimension.SetRange("Project No.", "Project Code");
                        ProjectsLineDimension.SetRange("Project Version No.", "Version Code");
                        ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                        ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                        ProjectsLineDimension.SetRange("Dimension Code", 'CC');

                        if ProjectsLineDimension.FINDFIRST then
                            Validate("Shortcut Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                        "New Lines" := grProjectsStructureLines1."Line No.";
                        "Line No." := grProjectsStructureLines1."Line No.";
                        Code := grProjectsStructureLines1.Code;
                        Description := grProjectsStructureLines1.Description;
                    end;
                end;
            end;

            trigger OnValidate()
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
            begin
                grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                grProjectsStructureLines1.SetRange(Version, "Version Code");
                grProjectsStructureLines1.SetRange("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                grProjectsStructureLines1.SetRange(Code, "Cost Code");

                if grProjectsStructureLines1.FindFirst() then begin
                    ProjectsLineDimension.SetRange("Project No.", "Project Code");
                    ProjectsLineDimension.SetRange("Project Version No.", "Version Code");
                    ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                    ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                    ProjectsLineDimension.SetRange("Dimension Code", 'CC');

                    IF ProjectsLineDimension.FindFirst() THEN
                        Validate("Shortcut Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                    "New Lines" := grProjectsStructureLines1."Line No.";
                    "Line No." := grProjectsStructureLines1."Line No.";
                    Code := grProjectsStructureLines1.Code;
                    Description := grProjectsStructureLines1.Description;
                end;
            end;
        }
        field(49; "New Lines"; Integer)
        {
            Caption = 'New Lines';
            Description = 'NC 50085 PA';
        }
        field(50; "Not Run OnInsert"; Boolean)
        {
            Caption = 'Not Run OnInsert';
            Description = 'NC 50085 PA';
        }
        field(51; "Work Version"; Boolean)
        {
            Caption = 'Work Version';
            Description = 'NC 50085 PA';
        }
        field(52; Reserve; Boolean)
        {
            Caption = 'Reserve';
            Description = 'NC 50085 PA';

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                lrProjectsBudgetEntryLink.SetRange("Main Entry No.", "Entry No.");
                lrProjectsBudgetEntryLink.SetRange("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.SetRange("Analysis Type", "Analysis Type");
                lrProjectsBudgetEntryLink.SetRange("Version Code", "Version Code");
                if lrProjectsBudgetEntryLink.FindFirst() then begin
                    repeat
                        lrProjectsBudgetEntryLink.Reserv := Reserve;
                        lrProjectsBudgetEntryLink.Modify();
                    until lrProjectsBudgetEntryLink.Next() = 0;
                end;
            end;
        }
        field(53; "Building Turn All"; Code[20])
        {
            Caption = 'Building Turn All';
            Description = 'NC 50086 PA';
        }
        field(60; "Date Plan"; Date)
        {
            Caption = 'Date (Plan)';
        }
        field(61; "Payment Doc. No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Purchase Line"."Document No." where("Forecast Entry" = field("Entry No.")));
            Caption = 'Pay Request No.';
        }
        field(62; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
            Description = 'NC 50085 PA';

            trigger OnValidate()
            var
                PBE: Record "Projects Budget Entry";
            begin
                WriteOffAmount := "Write Off Amount";

                if (AgrNo <> '') and ("Write Off Amount" > 0) then begin
                    PBE.SetCurrentKey("Work Version", "Agreement No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                    PBE.SetFilter("Contragent No.", '%1|%2', "Contragent No.", '');
                    PBE.SetRange("Agreement No.", '');
                    PBE.SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                    PBE.SetRange("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                    PBE.SetRange(Close, FALSE);
                    PBE.SETRANGE(Reserve, FALSE);
                    PBE.SETFILTER("Without VAT", '<>%1', 0);
                    PBE.SETFILTER("Write Off Amount", '<>0');
                    PBE.SETFILTER("Entry No.", '<>%1', "Entry No.");
                    IF PBE.FINDSET THEN
                        REPEAT
                            WriteOffAmount += PBE."Write Off Amount";
                        UNTIL PBE.NEXT = 0;
                    CheckCF(VendNo, AgrNo, WriteOffAmount);
                END;
            end;
        }
        field(63; NotVisible; Boolean)
        {
            Caption = 'Not Visible';
            Description = 'NC 50085 PA';
        }
        field(66; Reversed; Boolean)
        {

        }
        field(67; ID; Integer)
        {

        }
        field(69; "Reversed Without Entry"; Boolean)
        {

        }
        field(70; "Reversed ID"; Integer)
        {

        }
        field(71; "Without VAT (LCY)"; Decimal)
        {
            Caption = 'Without VAT (LCY)';
        }
        field(70001; "Problem Pmt. Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Editable = false;
            Caption = 'Problem Pmt. Document';

        }
        field(50077; "Currency Rate"; Decimal)
        {
            Caption = 'Currency Rate';
            Description = 'NC 51373 PA';

            trigger OnValidate()
            begin
                Validate(Curency);
            end;
        }
        field(51000; "Close Date"; Date)
        {
            Caption = 'Date Fact';
        }
        field(51010; "Payment Description"; Text[250])
        {
            Caption = 'Payment Description';
        }
        field(51020; Parentbool; Boolean)
        {
            Caption = 'Parent';
        }
    }

    keys
    {
        // key(PK; "Project Code", "Analysis Type", "Version Code", "Line No.", "Entry No.", "Project Turn Code", "Temp Line No.")
        // {
        //     Clustered = true;
        // }
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        // key(Key1; "Entry No.")
        // {

        // }
        key(Key2; "Project Code", "Analysis Type", "Version Code", "Line No.", Date)
        {

        }
        key(Key3; Date)
        {

        }
    }
    trigger OnInsert()
    begin
        "Create Date" := Today;
        "Create Time" := Time;
        "Create User" := UserId;
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
        if "Parent Entry" = 0 then
            "Parent Entry" := "Entry No.";
    end;

    var
        gvCreateRepeat: Boolean;
        WriteOffAmount: Decimal;
        AgrNo: Code[20];
        VendNo: Code[20];
        CurrencyDate: Date;
        gvBuildingTurn: Record "Building Turn";
        CurrExchRate: Record "Currency Exchange Rate";
        grProjectsStructureLines1: Record "Projects Structure Lines";
        lrProjectsBudgetEntryLink: Record "Projects Budget Entry Link";
        Text50000: Label 'The amount cannot be more than indicated in the "%1" agreement card in the breakdown by letter!';

    procedure GetNextEntryNo(): Integer
    var
        GLBudgetEntry: Record "Projects Budget Entry";
    begin

        GLBudgetEntry.SETCURRENTKEY("Entry No.");
        IF GLBudgetEntry.FINDLAST THEN
            EXIT(GLBudgetEntry."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    local procedure UpdateCurrencyFactor()
    var
        myInt: Integer;
    begin
        if Curency <> '' then begin
            if (Date = 0D) then
                CurrencyDate := WORKDATE
            else
                CurrencyDate := Date;

            if CurrencyDate > WorkDate() then begin
                if ("Currency Rate" <> 0) and (Curency = xRec.Curency) and (Date = xRec.Date) then
                    "Currency Factor" := 1 / "Currency Rate"
                else begin
                    CurrencyDate := WorkDate();
                    "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, Curency);
                    "Currency Rate" := 1 / "Currency Factor";
                end;
            end else begin
                "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, Curency);
                "Currency Rate" := 1 / "Currency Factor";
            end;
        end else
            "Currency Factor" := 0;
    end;

    local procedure ExchangeFCYtoLCY()
    var
        myInt: Integer;
    begin
        UpdateCurrencyFactor;

        if (Curency <> '') and ("Currency Factor" <> 0) then begin
            "Amount (LCY)" := Amount * (1 / "Currency Factor");
            "Without VAT (LCY)" := "Without VAT" * (1 / "Currency Factor")
        end else begin
            "Amount (LCY)" := Amount;
            "Without VAT (LCY)" := "Without VAT";
        end;
    end;

    procedure IsProductionProject() Result: Boolean
    var
        BldProj: Record "Building Project";
    begin
        Result := false;
        if "Project Code" <> '' then begin
            BldProj.GET("Project Code");
            Result := BldProj."Development/Production" = BldProj."Development/Production"::Production;
        end;
    end;

    procedure SetCreateRepeat(lvCreateRepeat: Boolean)
    begin
        gvCreateRepeat := lvCreateRepeat;
    end;

    procedure GetInvoiceNo() InvoiceNo: Code[20]
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
    begin
        if Close then begin
            PurchaseLine.SetCurrentKey("Forecast Entry");
            PurchaseLine.SetRange("Forecast Entry", "Entry No.");
            if PurchaseLine.FindFirst() then begin
                PurchaseHeader.SetRange("Document Type", PurchaseLine."Document Type");
                PurchaseHeader.SetRange("No.", PurchaseLine."Document No.");
                if PurchaseHeader.FindFirst() then begin
                    InvoiceNo := PurchaseHeader."No.";
                end;
            end;
        end;
        if InvoiceNo = '' then begin
            CalcFields("Payment Doc. No.");
            InvoiceNo := "Payment Doc. No.";
        end;
    end;

    procedure GetInvoiceDate() InvoiceDate: Date
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
    begin
        if Close then begin
            PurchaseLine.SetCurrentKey("Forecast Entry");
            PurchaseLine.SetRange("Forecast Entry", "Entry No.");
            if PurchaseLine.FindFirst() then begin
                PurchaseHeader.SetRange("Document Type", PurchaseLine."Document Type");
                PurchaseHeader.SetRange("No.", PurchaseLine."Document No.");
                if PurchaseHeader.FindFirst() then begin
                    PurchaseHeader.CalcFields("Paid Date Fact");
                    InvoiceDate := PurchaseHeader."Paid Date Fact";
                end;
            end;
        end;
    end;

    procedure CheckCF(VendNo: Code[20]; AgrNo: Code[20]; CheckAmt: Decimal)
    var
        VAD: Record "Vendor Agreement Details";
        PBE: Record "Projects Budget Entry";
        Amt: Decimal;
        VendAgr: Record "Vendor Agreement";
        GLSetup: Record "General Ledger Setup";
    begin
        if not "Not Run OnInsert" then
            if VendAgr.Get(VendNo, AgrNo) and not VendAgr.WithOut and not VendAgr."Don't Check CashFlow" then begin
                VAD.SetCurrentKey("Vendor No.", "Agreement No.", "Global Dimension 1 Code");
                VAD.SetRange("Vendor No.", VendNo);
                VAD.SetRange("Agreement No.", AgrNo);
                VAD.SetRange("Global Dimension 1 Code", "Shortcut Dimension 1 Code");
                VAD.CalcSums(AmountLCY);
                Amt := VAD.AmountLCY;

                PBE.SetCurrentKey("Contragent No.", "Agreement No.");
                PBE.SetRange("Contragent No.", VendNo);
                PBE.SetRange("Agreement No.", AgrNo);
                PBE.SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");

                if PBE.FINDSET then
                    repeat
                        Amt -= PBE."Without VAT (LCY)";
                    until PBE.Next() = 0;

                GLSetup.Get;
                if CheckAmt > Amt + GLSetup."Allow Diff in Check" then
                    Error(Text50000, AgrNo);
            end;
    end;

    procedure GetDefVersion1(pProjectCode: Code[20]) Ret: Code[20]
    var
        lrProjectVersion: Record "Project Version";
    begin
        lrProjectVersion.SetRange("Project Code", pProjectCode);
        lrProjectVersion.SetRange("Fixed Version");
        lrProjectVersion.SetRange("First Version", true);
        IF lrProjectVersion.Find('-') THEN
            Ret := lrProjectVersion."Version Code";
    end;
}