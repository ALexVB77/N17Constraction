page 70011 "Giv. Prod. Order Receipt"
{

    Caption = 'Giv. Prod. Order Receipt';
    PageType = ListPart;
    SourceTable = "Giv. Prod. Order Receipt";
    DelayedInsert = True;
    AutoSplitKey = True;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(Correction; Rec.Correction)
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
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
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        LastDocNo: Code[20];
        ism: codeunit "Isolated Storage Management GE";

    trigger OnFindRecord(Which: Text): Boolean
    begin

        IF rec.FIND(Which) THEN BEGIN
            SendMessage();
            EXIT(TRUE);
        END
        ELSE BEGIN
            SendMessage();
            EXIT(FALSE);
        END;
    end;

    trigger OnAfterGetCurrRecord()
    begin

        IF rec."Document No." <> LastDocNo THEN
            SendMessage();

        LastDocNo := rec."Document No.";

    end;

    procedure SendMessage()
    begin
        ism.setString('p50030_DocNo', Rec."Document No.");
        ism.setBool('p50030_Corr', Rec.Correction);
        ism.setBool('p50030_PostedRcpt', Rec.Posted);
    end;

}
