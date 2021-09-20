page 70264 TransfOrderDataIns
{

    Caption = 'Enter data for create new transfer order document';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(FromLocation; FromLocation)
                {
                    ApplicationArea = All;
                    ToolTip = 'From Location';
                    Caption = 'From Location Code';
                    trigger OnDrillDown()
                    begin
                        LocationList.LOOKUPMODE(TRUE);
                        IF LocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            LocationList.GETRECORD(Locations);
                            FromLocation := Locations.Code;
                            CLEAR(LocationList);
                        END;
                    end;
                }
                field(ToLocation; ToLocation)
                {
                    ApplicationArea = All;
                    ToolTip = 'To Location';
                    Caption = 'To location code';
                    trigger OnDrillDown()
                    begin
                        LocationList.LOOKUPMODE(TRUE);
                        IF LocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            LocationList.GETRECORD(Locations);
                            ToLocation := Locations.Code;
                            CLEAR(LocationList);
                        END;
                    end;
                }
                field(TransitLocation; TransitLocation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Transit Location';
                    Caption = 'Transit location code';
                }
            }
        }
    }
    var
        ToLocation: Code[20];
        FromLocation: Code[20];
        LocationList: Page "Location List";
        Locations: Record Location;
        ScanHelper: Codeunit "Scanning Helper";
        TransitLocation: Code[20];

    trigger OnOpenPage()
    begin
        Locations.RESET;
        Locations.SETRANGE("Use As In-Transit", TRUE);
        IF Locations.FINDFIRST THEN
            TransitLocation := Locations.Code;
    end;

    trigger OnClosePage()
    var
        EnterDataTxt: Label 'Enter From Location and To Location value code';
    begin
        IF (FromLocation = '') OR (ToLocation = '') THEN
            ERROR(EnterDataTxt);
        ScanHelper.CreateTrOrderHeader(FromLocation, ToLocation, TransitLocation);
    end;
}
