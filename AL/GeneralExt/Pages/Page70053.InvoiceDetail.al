page 70053 "Invoice Detail"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Invoice Detail";
    Caption = 'Invoice Detail';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Editable = false;
                field(AmountT; AmountT)
                {
                    ApplicationArea = All;
                }
            }
            repeater(Lines)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchInvHeader: Record "Purch. Inv. Header";
                    begin
                        if Rec."Document Type" = 0 then begin
                            PurchInvHeader.Get(Rec."Document No.");
                            Page.Run(138, PurchInvHeader);
                        end;
                        if Rec."Document Type" = 1 then;
                    end;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount with VAT"; Rec."Amount with VAT")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    var
        AmountT: Decimal;

    trigger OnOpenPage()
    begin
        AmountT := CalcAmount;
    end;

    local procedure CalcAmount() Ret: Decimal
    begin
        if Rec.FindSet() then
            repeat
                Ret := Ret + Rec.Amount;

            until Rec.Next() = 0;
    end;
}