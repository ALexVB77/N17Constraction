table 70094 "Vendor Agreement Details"
{
    DataClassification = ToBeClassified;
    DrillDownPageID = "Vendor Agreement Details List";
    LookupPageID = "Vendor Agreement Details List";
    Permissions = TableData 380 = r;
    fields
    {
        field(1; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "Vendor Agreement"."No.";

            trigger OnValidate()
            begin
                IF VendorAgreement.GET("Vendor No.", "Agreement No.") THEN
                    "Currency Code" := VendorAgreement."Currency Code";
            end;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(5; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                GeneralLedgerSetup.GET;
                IF DimensionValue.GET(GeneralLedgerSetup."Global Dimension 2 Code", "Global Dimension 2 Code") THEN
                    Description := DimensionValue.Name;
            end;
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Agreemnet Amount, with VAT';

            trigger OnValidate()
            begin

                IF NOT VendorAgreement.GET("Vendor No.", "Agreement No.") OR (VendorAgreement."Agreement Date" = 0D) THEN
                    VendorAgreement."Agreement Date" := WORKDATE;
                IF "Currency Code" <> '' THEN
                    AmountLCY := Amount * (1 / CurrExchRate.ExchangeRate(VendorAgreement."Agreement Date", "Currency Code"))
                ELSE
                    AmountLCY := Amount;


            end;
        }
        field(7; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';

            trigger OnValidate()
            begin
                if VendorAgreement.GET("Vendor No.", "Agreement No.") then
                    "Currency Code" := VendorAgreement."Currency Code";
            end;
        }
        field(11; "Agreement Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(12; "External Agreement No."; Text[30])
        {
            CalcFormula = Lookup("Vendor Agreement"."External Agreement No." WHERE("Vendor No." = FIELD("Vendor No."),
                                                                                    "No." = FIELD("Agreement No.")));
            Caption = 'External Agreement No.';
            FieldClass = FlowField;
        }
        field(13; "Agreement Date"; Date)
        {
            Caption = 'Agreement Date';
        }
        field(70001; "Agreement Amount"; Decimal)
        {
            Caption = 'Agreement Amount';
        }
        field(70005; "Vendor Name"; Text[250])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            FieldClass = FlowField;
        }
        field(70008; "VAT Amount"; Decimal)
        {
            Caption = 'Agreement VAT Amount';

        }
        field(70009; "Amount Without VAT"; Decimal)
        {
            Caption = 'Agreement Amount without VAT';

        }
        field(70010; "Building Turn All"; Code[20])
        {
            Caption = 'Stage';
            TableRelation = "Building Turn";


            trigger OnValidate()
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
                BuildingTurn: Record "Building Turn";
            begin
                if BuildingTurn.Get("Building Turn All") then begin
                    "Project Code" := BuildingTurn."Building project Code";
                    Validate("Global Dimension 1 Code", BuildingTurn."Turn Dimension Code");
                    grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                    grProjectsStructureLines1.SetRange("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                    grProjectsStructureLines1.SetFilter(Code, '%1&<>%2', "Cost Code", '');

                    if grProjectsStructureLines1.FindFirst() then begin
                        ProjectsLineDimension.SetRange("Project No.", "Project Code");
                        ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                        ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                        ProjectsLineDimension.SetRange("Dimension Code", 'CC');

                        if ProjectsLineDimension.FindFirst() then
                            Validate("Global Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                        "Project Line No." := grProjectsStructureLines1."Line No.";
                    end;
                end;
            end;
        }
        field(70011; "Cost Code"; Code[20])
        {
            Caption = 'Budget Item';

            trigger OnLookup()
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
            begin
                grProjectsStructureLines1.Reset();
                grProjectsStructureLines1.SetRange("Project Code", "Project Code");

                if grProjectsStructureLines1.FindFirst() then begin
                    if Page.RUNMODAL(Page::"Projects Article List", grProjectsStructureLines1) = Action::LookupOK then begin
                        "Cost Code" := grProjectsStructureLines1.Code;
                        ProjectsLineDimension.SetRange("Project No.", "Project Code");
                        ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                        ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                        ProjectsLineDimension.SETRANGE("Dimension Code", 'CC');

                        if ProjectsLineDimension.FindFirst() then
                            Validate("Global Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                        "Project Line No." := grProjectsStructureLines1."Line No.";
                        Description := grProjectsStructureLines1.Description;
                    end;
                end;
            end;

            trigger OnValidate()
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
                BuildingTurn: Record "Building Turn";
            begin
                if "Project Code" = '' then
                    Error(TEXT0001);
                grProjectsStructureLines1.Reset;
                grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                grProjectsStructureLines1.SetRange(Code, "Cost Code");

                if grProjectsStructureLines1.FINDFIRST then begin
                    ProjectsLineDimension.SetRange("Project No.", "Project Code");
                    ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                    ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                    ProjectsLineDimension.SetRange("Dimension Code", 'CC');

                    if ProjectsLineDimension.FINDFIRST then
                        Validate("Global Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                    "Project Line No." := grProjectsStructureLines1."Line No.";
                    Description := grProjectsStructureLines1.Description;
                end else
                    Error(TEXT0002, "Project Code", "Cost Code");
            end;
        }
        field(70012; "Project Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('PROJECT'));
        }
        field(70015; "Project Line No."; Integer)
        {
            Caption = 'Project Line No.';
        }
        field(70016; "Cost Type"; Code[20])
        {
            Caption = 'Cost Type';

            trigger OnLookup()
            var
                GLS: Record "General Ledger Setup";
                DimensionValue: Record "Dimension Value";
            begin
                GLS.Get;
                DimensionValue.SetRange("Dimension Code", GLS."Cost Type Dimension Code");
                if DimensionValue.FindFirst() then begin
                    if DimensionValue.Get(GLS."Cost Type Dimension Code", "Cost Type") then;
                    if Page.RunModal(Page::"Dimension Value List", DimensionValue) = Action::LookupOK then
                        "Cost Type" := DimensionValue.Code;
                end;
            end;
        }
        field(70017; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
        }
        field(70019; ByOrder; Boolean)
        {
            Caption = 'By Order';
        }
        field(70034; "Close Commitment"; Boolean)
        {
            Caption = 'Close Commitment';
        }
        field(70035; "Close Ordered"; Boolean)
        {
            Caption = 'Close Ordered';
        }
        field(70036; AmountLCY; Decimal)
        {
            Caption = 'Agreement Amount with VAT (LCY)';
        }
        field(70037; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';

        }
        field(70050; "Payed by Agreement"; Decimal)
        {
            CalcFormula = sum("Projects Budget Entry"."Without VAT" where("Agreement No." = field("Agreement No."),
                                                                           "Project Code" = field("Project Code"),
                                                                           "Shortcut Dimension 1 Code" = field("Global Dimension 1 Code"),
                                                                           "Shortcut Dimension 2 Code" = field("Global Dimension 2 Code"),
                                                                           Close = const(true)));
            Caption = 'Payed by Agreement with VAT';
            Editable = false;
            FieldClass = FlowField;

        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Agreement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        GeneralLedgerSetup: Record "general ledger setup";
        DimensionValue: Record "Dimension Value";
        grProjectsStructureLines1: Record "Projects Structure Lines";
        gvBuildingTurn: Record "Building Turn";
        CI: Record "Company Information";
        VendorAgreement: Record "Vendor Agreement";
        CurrencyDate: Date;
        CurrencyFactor: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        BuildingProject: Record "Building Project";
        SkipChekEmptyAmount: Boolean;
        TEXT0001: Label 'It is necessary to determine the construction object';
        TEXT0002: Label 'No article %2 found for construction object %1';
        FRAME: Label 'FRAME';
        Text50000: Label 'For the project %1 with the Production type, the fields Amount with VAT and Amount without VAT, etc. both are filled, or both are 0!';
        Text50001: Label 'Amount with VAT and Amount without VAT must not be equal to 0 for CostPlace %1!';

    trigger OnInsert()
    begin
        SkipChekEmptyAmount := true;
        IF "Line No." = 0 THEN
            "Line No." := GetNextEntryNo;

        if BuildingProject.Get("Project Code") then
            if not BuildingProject."Without Details" then
                TestField("Building Turn All");

        IF VendorAgreement.Get("Vendor No.", "Agreement No.") THEN
            "Currency Code" := VendorAgreement."Currency Code";

        Validate(Amount);
    end;

    trigger OnModify()
    begin
        IF BuildingProject.GET("Project Code") THEN
            IF BuildingProject."Development/Production" = BuildingProject."Development/Production"::Production THEN BEGIN
                IF NOT SkipChekEmptyAmount THEN
                    IF VendorAgreement.Get("Vendor No.", "Agreement No.") THEN
                        IF (NOT VendorAgreement.WithOut) AND (VendorAgreement."Agreement Group" = FRAME) THEN
                            IF ((Amount <> 0) AND ("Amount Without VAT" = 0)) OR ((Amount = 0) AND ("Amount Without VAT" <> 0)) THEN
                                ERROR(Text50000, "Project Code");
            END;

        Validate(Amount);
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    local procedure GetNextEntryNo(): Integer
    begin
        SetCurrentKey("Line No.");
        if FIND('+') then
            exit("Line No." + 1)
        else
            exit(1);
    end;

    procedure CalcGActuals(SortInit: Boolean; ProjectCode: Code[50]; LineNo: Integer; AgrNo: Code[50]; Dim1: Code[50]; Dim2: Code[50]; CostType: Code[50]; AnType: Boolean) gActuals: Decimal
    var
        ProjectsCostControlEntry: Record "Projects Cost Control Entry";
    begin
        gActuals := 0;

        if not SortInit then
            InitCostControlEntrySort(SortInit);

        ProjectsCostControlEntry.SetCurrentKey("Project Code", "Line No.", "Agreement No.", "Analysis Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
        ProjectsCostControlEntry.SetRange("Project Code", ProjectCode);
        ProjectsCostControlEntry.SetRange("Line No.", LineNo);
        ProjectsCostControlEntry.SetRange("Agreement No.", AgrNo);

        if AnType then begin
            ProjectsCostControlEntry."Analysis Type" := ProjectsCostControlEntry."Analysis Type"::Actuals;
            ProjectsCostControlEntry.SetCurrentKey("Analysis Type", ProjectsCostControlEntry."Analysis Type");
        end;

        ProjectsCostControlEntry.SetRange("Shortcut Dimension 1 Code", Dim1);
        ProjectsCostControlEntry.SetRange("Shortcut Dimension 1 Code", Dim2);
        ProjectsCostControlEntry.SetRange("Cost Type", CostType);

        if not ProjectsCostControlEntry.IsEmpty then begin
            ProjectsCostControlEntry.FindSet();
            repeat
                gActuals += ProjectsCostControlEntry."Amount Including VAT 2";
            until ProjectsCostControlEntry.Next() = 0;
        end;
    end;

    local procedure InitCostControlEntrySort(SortInit: Boolean)
    var
        ProjectsCostControlEntry: Record "Projects Cost Control Entry";
    begin
        SortInit := true;
        ProjectsCostControlEntry.Reset();
        ProjectsCostControlEntry.SetCurrentKey("Project Code", "Line No.", "Agreement No.", "Analysis Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
    end;

    procedure CalcPostedInvoice2(VendorNo: Code[20]; AgrNo: Code[20]; GlobDim1: Code[20]; GlobDim2: Code[20]; CostType: Code[20]) PostedInvoiceAmount: Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchInvHeader.SetRange("Pay-to Vendor No.", VendorNo);
        PurchInvHeader.SetRange("Agreement No.", AgrNo);
        if PurchInvHeader.FindSet() then begin
            repeat
                PurchInvLine.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
                PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                PurchInvLine.SetRange("Shortcut Dimension 1 Code", GlobDim1);
                PurchInvLine.SetRange("Shortcut Dimension 2 Code", GlobDim2);
                PurchInvLine.SetRange("Cost Type", CostType);
                PurchInvLine.CalcSums(Amount);
            until PurchInvHeader.Next() = 0;
        end;

        PurchCrMemoHdr.SetRange("Pay-to Vendor No.", VendorNo);
        PurchCrMemoHdr.SetRange("Agreement No.", AgrNo);
        if PurchCrMemoHdr.FindSet() then begin
            repeat
                PurchCrMemoLine.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
                PurchCrMemoLine.SetRange("Shortcut Dimension 1 Code", GlobDim1);
                PurchCrMemoLine.SetRange("Shortcut Dimension 2 Code", GlobDim2);
                PurchCrMemoLine.SetRange("Cost Type", CostType);
                PurchCrMemoLine.CalcSums(Amount);
                PostedInvoiceAmount += PurchCrMemoLine.Amount;
            until PurchCrMemoHdr.Next() = 0;
        end;
    end;

    procedure GetCommited(pAgreement: Code[20]; pCP: Code[20]; pCC: Code[20]) ReturnValue: Decimal
    var
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
    begin
        lrProjectsBudgetEntry.SetCurrentKey("Work Version", "Agreement No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        lrProjectsBudgetEntry.SetRange("Work Version", true);
        lrProjectsBudgetEntry.SetRange("Agreement No.", pAgreement);
        if pCP <> '' then
            lrProjectsBudgetEntry.SetRange("Shortcut Dimension 1 Code", pCP);
        if pCC <> '' then
            lrProjectsBudgetEntry.SetRange("Shortcut Dimension 2 Code", pCC);
        lrProjectsBudgetEntry.CalcSums("Without VAT");
        ReturnValue += lrProjectsBudgetEntry."Without VAT";
    end;

    procedure GetPlaneAmount(Lookup: Boolean) Amt: Decimal
    var
        PL: Record "Purchase Line";
        PH: Record "Purchase Header";
        PLt: Record "Purchase Line" temporary;
        gcduERPC: Codeunit "ERPC Funtions";
        Buff: Record "Inventory Buffer" temporary;
    begin
        PL.SetCurrentKey("Buy-from Vendor No.", "Agreement No.");
        PL.SetRange("Buy-from Vendor No.", "Vendor No.");
        PL.SetRange("Agreement No.", "Agreement No.");
        PL.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
        PL.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
        // NC AB >>
        // PL.SETRANGE(Paid, FALSE);
        // NC AB <<
        PL.SETRANGE(IW, FALSE);
        if PL.FindSet() then
            repeat
                if PH.GetStatusAppAct(PL."Document Type", PL."Document No.") in [PH."Status App Act"::Checker.AsInteger(),
                                                                                 PH."Status App Act"::Approve.AsInteger(),
                                                                                 PH."Status App Act"::Signing.AsInteger()] then
                    // NC AB >>
                    if not PH.GetPaymentInvPaidStatus() then
                        // NC AB <<
                        if PH.Get(PL."Document Type", PL."Document No.") and not PH."Problem Document" then begin
                            if Lookup then begin
                                PLt := PL;
                                PLt.Insert();
                            end else
                                Amt += gcduERPC.GetLinesDocumentsAmount(PL);
                        end;
            until PL.Next() = 0;

        if Lookup then
            Page.RunModal(0, PLt);
    end;


    procedure GetRemainAmt(): Decimal
    var
        VAD: Record "Vendor Agreement Details";
    begin
        VAD.SetCurrentKey("Agreement No.", "Vendor No.", "Global Dimension 1 Code");
        VAD.SetRange("Vendor No.", "Vendor No.");
        VAD.SetRange("Agreement No.", "Agreement No.");
        VAD.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
        VAD.SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
        VAD.SetRange("Cost Type", "Cost Type");
        if VAD.IsEmpty then
            VAD.SetRange("Cost Type");
        VAD.CalcSums(AmountLCY);
        exit(VAD.AmountLCY - CalcInvoice(true) - CalcPostedInvoice(true) - GetPlaneAmount(false));
    end;


    procedure CalcPostedInvoice(WithVAT: Boolean) Ret: Decimal
    var
        PIH: Record "Purch. Inv. Header";
        PIL: Record "Purch. Inv. Line";
        PIHC: Record "Purch. Cr. Memo Hdr.";
        PILC: Record "Purch. Cr. Memo Line";
    begin
        PIH.SetRange("Pay-to Vendor No.", "Vendor No.");
        PIH.SetRange("Agreement No.", "Agreement No.");
        if PIH.FindSet() then begin
            repeat
                PIL.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
                PIL.SetRange("Document No.", PIH."No.");
                PIL.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PIL.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                PIL.SetRange("Cost Type", "Cost Type");
                if WithVAT then begin
                    PIL.CalcSums("Amount Including VAT");
                    Ret += PIL."Amount Including VAT";
                end else begin
                    PIL.CalcSums(Amount);
                    Ret += PIL.Amount;
                end;
            until PIH.Next() = 0;
        end;

        PIHC.SetRange("Pay-to Vendor No.", "Vendor No.");
        PIHC.SetRange("Agreement No.", "Agreement No.");
        if PIHC.FindSet() then begin
            repeat
                PILC.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type");
                PILC.SetRange("Document No.", PIHC."No.");
                PILC.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PILC.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                PILC.SetRange("Cost Type", "Cost Type");
                if WithVAT then begin
                    PILC.CalcSums("Amount Including VAT");
                    Ret -= PILC."Amount Including VAT";
                end else begin
                    PILC.CalcSums(Amount);
                    Ret -= PILC.Amount;
                end;
            until PIHC.Next() = 0;
        end;
    end;


    procedure CalcInvoice(WithVAT: Boolean) Ret: Decimal
    var
        PH: Record "Purchase Header";
        PL: Record "Purchase Line";
        gcduERPC: Codeunit "ERPC Funtions";
    begin
        PH.SetRange("Document Type", PH."Document Type"::Invoice);
        PH.SetRange("Pay-to Vendor No.", "Vendor No.");
        PH.SetRange("Agreement No.", "Agreement No.");
        if PH.FINDSET then begin
            repeat
                PL.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                PL.SetRange("Document No.", PH."No.");
                PL.SetRange("Document Type", PH."Document Type");
                PL.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PL.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                if WithVAT then begin
                    if PL.FINDSET then
                        repeat
                            Ret += gcduERPC.GetLinesDocumentsAmount(PL);
                        until PL.NEXT = 0;
                end else begin
                    PL.CALCSUMS(Amount);
                    Ret += PL.Amount;
                end;
            until PH.NEXT = 0;
        end;
    end;


    procedure ShowPostedInvoice()
    var
        PIH: Record "Purch. Inv. Header";
        PIL: Record "Purch. Inv. Line";
        PIHC: Record "Purch. Cr. Memo Hdr.";
        PILC: Record "Purch. Cr. Memo Line";
        InvoiceDetail: Record "Invoice Detail" temporary;
    begin
        PIH.SetRange("Pay-to Vendor No.", "Vendor No.");
        PIH.SetRange("Agreement No.", "Agreement No.");
        if PIH.FindSet() then begin
            repeat
                PIL.SetRange("Document No.", PIH."No.");
                PIL.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PIL.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                PIL.SetRange("Cost Type", "Cost Type");

                if PIL.FindSet() then begin
                    repeat
                        InvoiceDetail."Document Type" := 0;
                        InvoiceDetail."Document No." := PIL."Document No.";
                        InvoiceDetail."Line No." := PIL."Line No.";
                        InvoiceDetail.Description := PIL.Description;
                        InvoiceDetail.Amount := PIL.Amount;
                        InvoiceDetail."Amount with VAT" := PIL."Amount Including VAT";
                        InvoiceDetail."Document Date" := PIH."Document Date";
                        InvoiceDetail.Insert();
                    until PIL.Next() = 0;
                end;
            until PIH.Next() = 0;
        end;

        PIHC.SetRange("Pay-to Vendor No.", "Vendor No.");
        PIHC.SetRange("Agreement No.", "Agreement No.");
        if PIHC.FindSet() then begin
            repeat
                PILC.SetRange("Document No.", PIHC."No.");
                PILC.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PILC.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                PILC.SetRange("Cost Type", "Cost Type");

                if PILC.FindSet() then begin
                    repeat
                        InvoiceDetail."Document Type" := 1;
                        InvoiceDetail."Document No." := PILC."Document No.";
                        InvoiceDetail."Line No." := PILC."Line No.";
                        InvoiceDetail.Description := PILC.Description;
                        InvoiceDetail.Amount := -PILC.Amount;
                        InvoiceDetail."Amount with VAT" := -PILC."Amount Including VAT";
                        InvoiceDetail."Document Date" := PIHC."Document Date";
                        InvoiceDetail.Insert();
                    until PILC.Next() = 0;
                end;
            until PIHC.Next() = 0;
        end;

        Page.Run(70243, InvoiceDetail);
    end;


    procedure GetRemainAmt2(): Decimal
    var
        VAD: Record "Vendor Agreement Details";
        Text001: Label '%1 = Amount 70094: %2, Invoices: %3, Posted Invoices: %4, On Approval: %5';
    begin
        VAD.SetCurrentKey("Agreement No.", "Vendor No.", "Global Dimension 1 Code");
        VAD.SetRange("Vendor No.", "Vendor No.");
        VAD.SetRange("Agreement No.", "Agreement No.");
        VAD.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
        VAD.SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
        VAD.SetRange("Cost Type", "Cost Type");
        VAD.CalcSums(AmountLCY);
        Message(Text001,
                VAD.AmountLCY - CalcInvoice(true) - CalcPostedInvoice(true) - GetPlaneAmount(false),
                VAD.AmountLCY, -CalcInvoice(true), -CalcPostedInvoice(true), -GetPlaneAmount(false));
    end;

    procedure ShowInvoice()
    var
        PH: Record "Purchase Header";
        PL: Record "Purchase Line";
        gcduERPC: Codeunit "ERPC Funtions";
    begin
        PH.SetRange("Document Type", PH."Document Type"::Invoice);
        PH.SetRange("Pay-to Vendor No.", "Vendor No.");
        PH.SetRange("Agreement No.", "Agreement No.");
        if PH.FindSet() then begin
            repeat
                PL.SetCurrentKey("Document No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                PL.SetRange("Document No.", PH."No.");
                PL.SetRange("Document Type", PH."Document Type");
                PL.SetRange("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PL.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                if PL.FindSet() then
                    PH.Mark(true);
            until PH.Next() = 0;
        end;

        PH.MarkedOnly(true);
        Page.RunModal(0, PH);
    end;
}