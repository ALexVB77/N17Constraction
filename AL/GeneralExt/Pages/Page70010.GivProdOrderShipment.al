page 70010 "Giv. Prod. Order Shipment"
{

    Caption = 'Giv. Prod. Order Shipment';
    PageType = ListPart;
    SourceTable = "Giv. Prod. Order Shipment";
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
        ism.setString('p50029_DocNo', Rec."Document No.");
        ism.setBool('p50029_Corr', Rec.Correction);
    end;
}
