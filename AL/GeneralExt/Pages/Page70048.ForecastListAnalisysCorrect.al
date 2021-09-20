page 70048 "Forecast List Analisys Correct"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Projects Budget Entry";
    SourceTableView = where("Not Run OnInsert" = const(false));
    SaveValues = false;
    DelayedInsert = true;
    Caption = 'Transaction Register';
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(Title)
            {
                ShowCaption = false;
                field(Label; TEXT001)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = StrongAccent;
                }
            }
            group(Header)
            {
                field(DateHeadrer; grProjectsBudgetEntry.Date)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DescriptionHeadrer; grProjectsBudgetEntry.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description2Headrer; grProjectsBudgetEntry."Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(WithoutVAT; grProjectsBudgetEntry."Without VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; GetSum)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Remain; grProjectsBudgetEntry."Without VAT" - GetSum)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    Editable = DateEditable;
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        lrPL: Record "Purchase Line";
                        lrPH: Record "Purchase Header";
                    begin
                        if Rec.Close then begin
                            lrPL.SetCurrentKey("Forecast Entry");
                            lrPL.SetRange("Forecast Entry", Rec."Entry No.");

                            if lrPL.FINDFIRST then begin
                                lrPH.SetRange("Document Type", lrPL."Document Type");
                                lrPH.SetRange("No.", lrPL."Document No.");

                                IF lrPH.FindFirst() then begin
                                    Page.Run(70000, lrPH);
                                end;
                            end;
                        end;
                    end;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Without VAT"; Rec."Without VAT")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Rec.Amount < Rec."Write Off Amount" then begin
                            Message(TEXT0009);
                            Rec."Write Off Amount" := xRec."Write Off Amount";
                        end;

                        CurrPage.Update();
                    end;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        TEXT001: Label 'You must select the Cash Flow records from which you want to write off this amount';
        TEXT0009: Label 'The amount of the remainder of the line has been exceeded!';
        TEXT0010: Label 'The sum of the remainder of the distribution is not 0.';
        grProjectsBudgetEntry: Record "Projects Budget Entry";
        DateEditable: Boolean;
        OldAgreement: Code[20];
        TemplateCode: Code[20];
        CostPlaceFlt: Text[200];
        CostCodeFlt: Text[200];

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction <> Action::Cancel) then
            if ((grProjectsBudgetEntry."Without VAT" - GetSum) <> 0) and (GetSum <> 0) then
                Error(TEXT0010);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Close then
            DateEditable := false
        else
            DateEditable := true;

        OldAgreement := Rec."Agreement No.";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Not Run OnInsert" := true;
        Rec."Project Code" := TemplateCode;
        Rec."Version Code" := Rec.GetDefVersion1(TemplateCode);

        if CostPlaceFlt <> '' then
            Rec.Validate("Building Turn", CostPlaceFlt);

        if CostCodeFlt <> '' then
            Rec.Validate("Cost Code", CostCodeFlt);
    end;

    procedure GetSum() Ret: Decimal
    var
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
    begin
        lrProjectsBudgetEntry.SetRange("Project Code", grProjectsBudgetEntry."Project Code");
        lrProjectsBudgetEntry.SetRange("Project Turn Code", grProjectsBudgetEntry."Project Turn Code");
        lrProjectsBudgetEntry.SetRange("Cost Code", grProjectsBudgetEntry."Cost Code");
        lrProjectsBudgetEntry.SetFilter("Contragent No.", '%1|%2', '', grProjectsBudgetEntry."Contragent No.");
        lrProjectsBudgetEntry.SetRange("Agreement No.", '');
        lrProjectsBudgetEntry.SetFilter("Without VAT", '<>%1', 0);
        if lrProjectsBudgetEntry.FindSet() then begin
            repeat
                Ret := Ret + lrProjectsBudgetEntry."Write Off Amount";
            until lrProjectsBudgetEntry.Next() = 0;
        end;
        Sleep(1);
    end;

    procedure SetData(pProjectsBudgetEntry: Record "Projects Budget Entry")
    begin
        grProjectsBudgetEntry := pProjectsBudgetEntry;
    end;
}