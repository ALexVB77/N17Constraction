tableextension 92451 "Item Recept Header (GE)" extends "Item Receipt Header"
{
    fields
    {
        field(50000; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = vendor;
        }
        field(50001; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."));
        }
        field(50002; "Giv. Prod. Order No."; Code[20])
        {
            Caption = 'Giv. Prod. Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Giv. Prod. Order";
        }
        field(50003; "Shipment Act No."; Code[20])
        {
            Caption = 'Shipment Act No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Shipment Header";
        }
    }
}
