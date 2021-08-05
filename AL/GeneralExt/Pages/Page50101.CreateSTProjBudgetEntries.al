page 50101 "Create ST Proj Budget Entries"
{
    PageType = List;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = "Projects Budget Entry";
    SourceTableTemporary = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Without VAT (LCY)"; Rec."Without VAT (LCY)")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Payment Description"; Rec."Payment Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Date := Today;
        if EntryNo = 0 then
            EntryNo := 1;
        Rec."Entry No." := EntryNo;
        EntryNo := EntryNo + 1;
        Rec."Project Code" := gProjBudEntry."Project Code";
        Rec."Shortcut Dimension 1 Code" := gProjBudEntry."Shortcut Dimension 1 Code";
        Rec."Parent Entry" := gProjBudEntry."Entry No.";
        if gProjBudEntry."Shortcut Dimension 2 Code" <> '' then
            rec."Shortcut Dimension 2 Code" := gProjBudEntry."Shortcut Dimension 2 Code";
        if gProjBudEntry."Contragent No." <> '' then begin
            Rec."Contragent Type" := gProjBudEntry."Contragent Type";
            Rec."Contragent No." := gProjBudEntry."Contragent No.";
            rec."Contragent Name" := gProjBudEntry."Contragent Name";
        end;
        if gProjBudEntry."Agreement No." <> '' then begin
            Rec."Agreement No." := gProjBudEntry."Agreement No.";
            Rec."External Agreement No." := gProjBudEntry."External Agreement No.";
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        //if CloseAction = Action::LookupOK then
        CreateSTLines();
    end;

    var
        gProjBudEntry: Record "Projects Budget Entry";
        gAmount: decimal;
        EntryNo: Integer;

    procedure SetProjBudEntry(pPBE: Record "Projects Budget Entry")
    begin
        gProjBudEntry := pPBE;
        gAmount := pPBE."Without VAT (LCY)";
    end;

    procedure GetResultAmount(): decimal
    begin
        exit(gAmount);
    end;

    procedure CreateSTLines()
    var
        lPBE: Record "Projects Budget Entry";
        lAmount: Decimal;
        lTextErr001: Label 'Parent Entry amount %1 exeeded by %2';
    begin
        lAmount := gAmount;
        if Rec.FindSet() then
            repeat
                Rec.TestField("Shortcut Dimension 2 Code");
                Rec.TestField("Contragent No.");
                Rec.TestField("Agreement No.");
                Rec.TestField("Without VAT (LCY)");
                lPBE := Rec;
                lPBE."Entry No." := 0;
                lPBE.insert(true);
                lAmount := lAmount - Rec."Without VAT (LCY)";
            until Rec.Next() = 0;
        if lAmount < 0 then
            Error(lTextErr001, gProjBudEntry."Without VAT (LCY)", Abs(lAmount));
        gAmount := lAmount;
        lPBE.Get(gProjBudEntry."Entry No.");
        lPBE."Without VAT (LCY)" := gAmount;
        lPBE.Modify();
    end;
}