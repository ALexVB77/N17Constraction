page 99916 MatOrderDataIns
{

    Caption = 'Enter data for create new material transfer order document';
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
                    Caption = 'From Location code';
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
                    ToolTip = ' To Location';
                    Caption = 'To Location Code';
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
                    Caption = 'Transit Location code';
                }
                field(CustomerNo; CustomerNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer No.';
                    Caption = 'Customer Code';
                    trigger OnDrillDown()
                    var
                        CustomerList: Page "Customer List";
                        Customer: Record Customer;
                    begin
                        CustomerList.LOOKUPMODE(TRUE);
                        IF CustomerList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            CustomerList.GETRECORD(Customer);
                            CustomerNo := Customer."No.";
                            CLEAR(CustomerList);
                        END;
                    end;
                }
                field(AgreementNo; AgreementNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Agreement No';
                    Caption = 'Agreement No.';
                    trigger OnDrillDown()
                    var
                        AgreementList: Page "Customer Agreements";
                        Agreement: Record "Customer Agreement";
                        InsertCustTxt: Label 'Please enter Customer Code';
                    begin
                        IF CustomerNo = '' THEN
                            ERROR(InsertCustTxt);
                        AgreementList.LOOKUPMODE(TRUE);
                        Agreement.SETRANGE("Customer No.", CustomerNo);
                        Agreement.SETRANGE(Active, TRUE);
                        AgreementList.SETTABLEVIEW(Agreement);
                        IF AgreementList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            AgreementList.GETRECORD(Agreement);
                            AgreementNo := Agreement."No.";
                            CLEAR(AgreementList);
                        END;
                    end;
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
        CustomerNo: Code[20];
        AgreementNo: Code[20];

    trigger OnOpenPage()
    begin
        Locations.RESET;
        Locations.SETRANGE("Use As In-Transit", TRUE);
        IF Locations.FINDFIRST THEN
            TransitLocation := Locations.Code;
    end;

    trigger OnClosePage()
    var
        EnterDataTxt: label 'Enter From Location and To Location value code';
    begin
        ;
        IF (FromLocation = '') OR (ToLocation = '') OR (CustomerNo = '') OR (AgreementNo = '') THEN
            ERROR(EnterDataTxt);
        ScanHelper.CreateMatOrderHeader(FromLocation, ToLocation, TransitLocation, CustomerNo, AgreementNo);
    end;
}
