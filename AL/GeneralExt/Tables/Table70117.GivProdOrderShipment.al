table 70117 "Giv. Prod. Order Shipment"
{
    Caption = 'Giv. Prod. Order Shipment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Giv. Prod. Order";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Correction; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Shipment Header"."No.";
            trigger OnValidate()
            var
                myInt: Integer;
            begin

                IF NOT ItemShpmtHdr.GET("Document No.") THEN
                    CLEAR(ItemShpmtHdr);

                VALIDATE("Posting Date", ItemShpmtHdr."Posting Date");
                VALIDATE(Description, COPYSTR(ItemShpmtHdr."Posting Description", 1, MAXSTRLEN(Description)));

            end;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(key1; "Document No.")
        {

        }
    }
    var

        ItemShpmtHdr: Record "Item Shipment Header";

}
