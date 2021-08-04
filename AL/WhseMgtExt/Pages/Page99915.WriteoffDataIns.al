page 99915 WriteoffDataIns
{

    Caption = 'Enter data for create new write-off document';
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
                    Caption = 'From location code';
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
            }
        }
    }
    var
        FromLocation: Code[20];
        LocationList: Page "Location List";
        Locations: Record Location;
        ScanHelper: Codeunit "Scanning Helper";
        TransitLocation: Code[20];
        CustomerNo: Code[20];
        AgreementNo: Code[20];
        ToLocation: Code[20];

    trigger OnClosePage()
    var
        EnterDataTxt: Label 'Enter From Location value code';
    begin
        IF FromLocation = '' THEN
            ERROR(EnterDataTxt);
        ScanHelper.CreateWriteoffHeader(FromLocation, ToLocation, TransitLocation, CustomerNo, AgreementNo);
    end;
}
