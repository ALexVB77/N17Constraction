tableextension 80081 "Gen. Journal Line (Ext)" extends "Gen. Journal Line"
{
    fields
    {
        field(50020; "Notify Customer"; boolean)
        {
            Caption = 'Notify Customer';
        }
        field(50030; Gift; Boolean)
        {
            Caption = 'Gift';
        }
        field(70020; "IW Document No."; Code[20])
        {
            Description = 'NC 50112 AB';
            Caption = 'IW Document No.';
        }
    }

    var
        MappingVersionID: Guid;
        MapDim1, MapDim2 : code[20];

    procedure SetIFRSMappingValues()
    var
        GLSetup: Record "General Ledger Setup";
        MappingVer: Record "IFRS Stat. Acc. Map. Vers.";
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        GLSetup.Get();
        if '' in [GLSetup."IFRS Stat. Acc. Map. Code", GLSetup."IFRS Stat. Acc. Map. Vers.Code"] then
            exit;
        MappingVersionID := MappingVer."Version ID";

        PurchSetup.Get();
        MapDim1 := PurchSetup."Cost Place Dimension";
        MapDim2 := PurchSetup."Cost Code Dimension";
    end;

    procedure GetIFRSMappingValues(var MappingVerID: Guid; var Dim1: code[20]; var Dim2: code[20])
    begin
        MappingVerID := MappingVersionID;
        Dim1 := MapDim1;
        Dim2 := MapDim2;
    end;
}
