codeunit 70025 "CRM Object Xml to Json"
{
    TableNo = "Web Request Queue";

    trigger OnRun()
    begin
        ExportScheme();
    end;

    var
        //All
        ObjectTypeX: Label 'Publisher/IntegrationInformation', Locked = true;
        SoapObjectContainerX: Label '//crm_objects/object', Locked = true;
        TargetCompanyNameX: Label '@Target CRM CompanyName', Locked = true;

        CustomerSearchInReceivingData: Label '#CustomerSearchInReceivingData#', Locked = true;
        CustomerSearchReserveContact: Label '#ReserveContact#', Locked = true;
        CustomerSearchCurrentCompany: Label '#CurrentCompany#', Locked = true;


        //Unit
        UnitX: Label 'NCCObjects/NCCObject/Unit/', Locked = true;
        UnitIdX: Label 'NCCObjects/NCCObject/Unit/BaseData/ObjectID', Locked = true;
        UnitProjectIdX: Label 'NCCObjects/NCCObject/Unit/BaseData/ObjectParentID', Locked = true;
        UnitBuyerNodesX: label 'Buyers/Buyer', Locked = true;
        UnitBaseDataX: Label 'NCCObjects/NCCObject/Unit/BaseData/', Locked = true;
        ObjectParentIdX: Label 'ObjectParentID', Locked = true;
        ReservingContactX: Label 'ContactID', Locked = true;
        InvestmentObjectX: Label 'Name', Locked = true;
        BlockNumberX: Label 'BlockNumber', Locked = True;
        ApartmentNumberX: Label 'ApartmentNumber', Locked = true;
        ApartmentOriginTypeX: Label 'ObjectAttributes/TypeOfBuildings/TypeOfBuilding/KeyName', Locked = true;
        ApartmentUnitAreaM2X: Label 'Measurements/UnitAreaM2/ActualValue', Locked = true;
        ExpectedRegDateX: Label 'KeyDates/ExpectedRegistrationPeriod', Locked = true;
        ActualDateX: Label 'KeyDates/Sales/ActualDate', Locked = true;
        ExpectedDateX: Label 'KeyDates/HandedOver/ExpectedDate', Locked = true;
        UnitBuyerX: Label 'BaseData/ObjectID', Locked = true;
        UnitBuyerContactX: Label 'BaseData/ContactID', Locked = true;
        UnitBuyerContractX: Label 'BaseData/ContractID', Locked = true;
        UnitBuyerOwnershipPrcX: Label 'BaseData/OwnershipPercentage', Locked = true;
        UnitBuyerIsActiveX: Label 'BaseData/IsActive', Locked = true;

        //Contact
        ContactX: Label 'NCCObjects/NCCObject/Contact/', Locked = true;
        ContactIdX: Label 'NCCObjects/NCCObject/Contact/BaseData/ObjectID', Locked = true;
        ContactBaseDataX: Label 'NCCObjects/NCCObject/Contact/BaseData/', Locked = true;
        PersonDataX: Label 'PersonData', Locked = true;
        LastNameX: Label 'LastName', Locked = true;
        FirstNameX: Label 'FirstName', Locked = true;
        MiddleNameX: Label 'MiddleName', Locked = true;
        PhysicalAddressX: Label 'PhysicalAddresses/PhysicalAddress', Locked = true;
        PostalCityX: Label 'PostalCity', Locked = true;
        CountryCodeX: Label 'CountryCode', Locked = true;
        AddressLineX: Label 'AddressLine', Locked = true;
        PostalCodeX: Label 'PostalCode', Locked = true;
        ElectronicAddressesX: Label 'ElectronicAddresses', Locked = true;
        ElectronicAddressX: Label 'ElectronicAddress', Locked = true;
        ProtocolX: Label 'Protocol', Locked = true;
        ContactPhoneX: Label 'Phone', Locked = true;
        ContactEmailX: Label 'Email', Locked = true;
        ContactAddressLine1X: Label 'ContactAddressLine1', Locked = true;
        ContactUpdateExistingX: Label '@ContactUpdateExisting', Locked = true;

        //Contract
        ContractX: Label 'NCCObjects/NCCObject/Contract/', Locked = true;
        ContractIdX: Label 'NCCObjects/NCCObject/Contract/BaseData/ObjectID', Locked = true;
        ContractUnitIdX: Label 'NCCObjects/NCCObject/Contract/BaseData/ObjectParentID', Locked = true;
        ContractBaseDataX: Label 'NCCObjects/NCCObject/Contract/BaseData/', Locked = true;
        ContractNoX: Label 'Name', Locked = true;
        ContractTypeX: Label 'ObjectType', Locked = true;
        ContractStatusX: Label 'ObjectStatus/KeyName', Locked = true;
        ContractCancelStatusX: Label 'CancelStatus/KeyName', Locked = true;
        ContractIsActiveX: Label 'IsActive', Locked = true;
        ExtAgreementNoX: Label 'ObjectNumber', Locked = true;
        AgreementAmountX: Label 'FinanceData/ContractPrice', Locked = true;
        FinishingInclX: Label 'FinanceData/FullFinishingPrice', Locked = true;
        ContractBuyerNodesX: Label 'Buyers/Buyer', Locked = true;
        ContractBuyerX: Label 'BaseData/ObjectID', Locked = true;

        //Errors
        ContactUnitNotFoundErr: Label 'Unit of Contact or Reserving Contact is not found';
        ContractUnitNotFoundErr: Label 'Unit %1 of Contract is not found';

        ContractAlreadyLinkedErr: Label 'Another Customer already has the same Agreement Crm Guid, Old Customer No.=%1, New Customer No.=%2';
        ContractNotRegisteredErr: Label 'Contract is not registered, Type %1, Status %2';
        ContractNotSignedErr: Label 'Contract is not signed, Type %1, Status %2';
        ContractNotCreatedErr: Label 'Agreement could not be created. Some of contacts are not found';
        ContractNotCreated2Err: Label 'Agreement could not be created. Some of contacts are not created';
        ContractBuyersNotFoundErr: Label 'Buyers are not found';
        ContractContactNotFound: Label 'Contact %1 is not found, Parent Object Id (Unit) %2, Buyer %3';
        BadSoapEnvFormatErr: Label 'Bad soap envelope format';
        ImportActionNotAllowedErr: Label 'Import action %1 is not allowed';
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.';
        InvalidPhoneNoErr: Label 'The phone no. "%1" is not valid.';
        KeyErr: Label 'No field key is specified!';
        NoObjectIdErr: Label 'No ObjectID in XML Document';
        NoParentObjectIdErr: Label 'No ParentObjectID in XML Document';
        ProjectNotFoundErr: Label 'ProjectId %1 is not found in %2';
        UnknownObjectTypeErr: Label 'Unknown type of Object %1';
        NoParsedDataOnImportErr: Label 'Import of object %1 interrupted. No parsed data';
        FieldNameDoesNotExistErr: label 'Object field name %1 does not exist';
        RecordMustBeTemporaryErr: Label '%1 record must be temporary';

        StartSessionErr: Label 'The session was not started successfully';


        //Messages
        AllUpToDateMsg: Label 'All is up to date';
        ContactProcessedMsg: Label 'Customer No. %1';
        ContractCreatedMsg: Label 'Customer Agreement %1 has been created, %2 = %3, %4 = %5';
        ContractUpdatedMsg: Label 'Customer Agreement %1 has been updated, %2 = %3, %4 = %5';
        EmptyHttpRequestBody: Label 'Http request body is empty';
        NoInvestObjectMsg: Label 'Investment object is not specified';
        InvestmentObjectCreatedMsg: label 'Investment object %1 was created';
        InvestmentObjectUpdatedMsg: label 'Investment object %1 was updated';
        UnitCreatedMsg: Label 'Unit and Buyer %1 are created';
        UnitUpdatedMsg: Label 'Unit and Buyer %1 was updated';

        //==
        ObjectDataElementG: Dictionary of [Text, Text];
        ObjectDataElementListG: List of [Dictionary of [Text, Text]];
        ParsedObjectsG: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        CrmInteractCompanyListG: List of [Text];

    procedure ExportScheme() Result: Text
    var
        TxtBuilder: TextBuilder;
        BaseXPath: Text;

        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStrm: OutStream;
        InStrm: InStream;
        FullFileName: Text;
        FilenameGuid: Guid;

    begin
        TxtBuilder.AppendLine('UNIT');
        TxtBuilder.AppendLine(T('objectType', ObjectTypeX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('objectId', UnitIdX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('projectId', UnitProjectIdX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('reservingContactId', JoinX(UnitBaseDataX, ReservingContactX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('investmentObject', JoinX(UnitBaseDataX, InvestmentObjectX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('blockNumber', JoinX(UnitBaseDataX, BlockNumberX), Enum::"Json Field Type"::String, false));
        TxtBuilder.AppendLine(T('apartmentNumber', JoinX(UnitBaseDataX, ApartmentNumberX), Enum::"Json Field Type"::String, false));
        TxtBuilder.AppendLine(T('apartmentOriginType', JoinX(UnitX, ApartmentOriginTypeX), Enum::"Json Field Type"::String, false));
        TxtBuilder.AppendLine(T('apartmentUnitAreaM2', JoinX(UnitX, ApartmentUnitAreaM2X), Enum::"Json Field Type"::Number, false));
        TxtBuilder.AppendLine(T('expectedRegDate', JoinX(UnitX, ExpectedRegDateX), Enum::"Json Field Type"::String, false, 'dd.mm.yyyy date format'));
        TxtBuilder.AppendLine(T('actualDate', JoinX(UnitX, ActualDateX), Enum::"Json Field Type"::String, false, 'dd.mm.yyyy date format'));
        TxtBuilder.AppendLine(T('expectedDate', JoinX(UnitX, ExpectedDateX), Enum::"Json Field Type"::String, false, 'dd.mm.yyyy date format'));
        BaseXPath := JoinX(UnitX, UnitBuyerNodesX);
        TxtBuilder.AppendLine(T('buyers', BaseXPath, Enum::"Json Field Type"::Object, false));
        TxtBuilder.AppendLine(T('buyerId', JoinX(BaseXPath, UnitBuyerX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('contactId', JoinX(BaseXPath, UnitBuyerContactX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('contractId', JoinX(BaseXPath, UnitBuyerContractX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('ownershipPrc', JoinX(BaseXPath, UnitBuyerOwnershipPrcX), Enum::"Json Field Type"::Number, false));
        TxtBuilder.AppendLine(T('buyerIsActive', JoinX(BaseXPath, UnitBuyerIsActiveX), Enum::"Json Field Type"::Boolean, false));

        //-------

        TxtBuilder.AppendLine('CONTACT');
        TxtBuilder.AppendLine(T('objectType', ObjectTypeX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('objectId', ContactIdX, Enum::"Json Field Type"::String, true));
        BaseXPath := JoinX(ContactX, PersonDataX);
        TxtBuilder.AppendLine(T('lastName', JoinX(BaseXPath, LastNameX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('firstName', JoinX(BaseXPath, FirstNameX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('middleName', JoinX(BaseXPath, MiddleNameX), Enum::"Json Field Type"::String, true));
        BaseXPath := JoinX(ContactX, PhysicalAddressX);
        TxtBuilder.AppendLine(StrSubstNo('contact physical address %1 is not mandatory', BaseXPath));
        TxtBuilder.AppendLine(T('postalCity', JoinX(BaseXPath, PostalCityX), Enum::"Json Field Type"::String, false));
        TxtBuilder.AppendLine(T('countryCode', JoinX(BaseXPath, CountryCodeX), Enum::"Json Field Type"::String, false));
        TxtBuilder.AppendLine(T('postalCode', JoinX(BaseXPath, PostalCodeX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('addressLine', JoinX(BaseXPath, AddressLineX + '1'), Enum::"Json Field Type"::String, false, 'merged AddressLine1[2,3] fields'));
        TxtBuilder.AppendLine(T('addressLine', JoinX(BaseXPath, AddressLineX + '2'), Enum::"Json Field Type"::String, false, 'merged AddressLine1[2,3] fields'));
        TxtBuilder.AppendLine(T('addressLine', JoinX(BaseXPath, AddressLineX + '3'), Enum::"Json Field Type"::String, false, 'merged AddressLine1[2,3] fields'));
        BaseXPath := JoinX(ContactX, ElectronicAddressesX);
        TxtBuilder.AppendLine(StrSubstNo('contact emails and phones node %1 is not mandatory', BaseXPath));
        TxtBuilder.AppendLine(T('phone', JoinX(BaseXPath, AddressLineX + '1'), Enum::"Json Field Type"::Array, false,
            StrSubstNo('array of valid phones[string] if %1 has value "%2"', JoinX(BaseXPath, ProtocolX), ContactPhoneX)));
        TxtBuilder.AppendLine(T('email', JoinX(BaseXPath, AddressLineX + '1'), Enum::"Json Field Type"::Array, false,
            StrSubstNo('array of valid emails[string] if %1 has value "%2"', JoinX(BaseXPath, ProtocolX), ContactEmailX)));


        TxtBuilder.AppendLine('CONTRACT');
        TxtBuilder.AppendLine(T('objectType', ObjectTypeX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('objectId', ContractIdX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('unitId', ContractUnitIdX, Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('no', JoinX(ContractBaseDataX, ContractNoX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('type', JoinX(ContractBaseDataX, ContractTypeX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('status', JoinX(ContractBaseDataX, ContractStatusX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('cancelStatus', JoinX(ContractBaseDataX, ContractCancelStatusX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('isActive', JoinX(ContractBaseDataX, ContractIsActiveX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('externalAgreementNo', JoinX(ContractBaseDataX, ExtAgreementNoX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('agreementAmount', JoinX(ContractX, AgreementAmountX), Enum::"Json Field Type"::String, true));
        TxtBuilder.AppendLine(T('finishingIncl', JoinX(ContractX, FinishingInclX), Enum::"Json Field Type"::String, false));
        BaseXPath := JoinX(ContractX, ContractBuyerNodesX);
        TxtBuilder.AppendLine(StrSubstNo('contract buyer list %1 is not mandatory', BaseXPath));
        TxtBuilder.AppendLine(T('buyers', JoinX(ContractX, ContractBuyerX), Enum::"Json Field Type"::Array, false, 'array of buyer ids[string]'));


        FullFileName := Format(CreateGuid()) + '.txt';
        TempBlob.CreateOutStream(OutStrm, TextEncoding::UTF8);
        OutStrm.WriteText(TxtBuilder.ToText());
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, false));

    end;

    local procedure T(FldName: Text; Xpath: Text; JsonFieldType: Enum "Json Field Type"; Mandatory: Boolean) Result: Text
    begin
        Result := T(FldName, Xpath, JsonFieldType, Mandatory, '');
    end;

    local procedure T(FldName: Text; Xpath: Text; JsonFieldType: Enum "Json Field Type"; Mandatory: Boolean; Description: Text) Result: Text
    var
        CsvLineTemplate: Label '%1;%2;%3;%4;%5', locked = true;
    begin
        Result := StrSubstNo(CsvLineTemplate, FldName, Xpath, JsonFieldType, Mandatory, Description);
    end;

    local procedure JoinX(RootXPath: Text; ChildXPath: Text) Result: Text
    begin
        if not RootXPath.EndsWith('/') then
            RootXPath := RootXPath + '/';
        Result := RootXPath + ChildXPath;
    end;


}
