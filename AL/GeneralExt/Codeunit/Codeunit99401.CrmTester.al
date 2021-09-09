codeunit 99401 "CRM Tester"
{
    TableNo = "Web Request Queue";

    trigger OnRun()
    begin
        //
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


    procedure GetApartmentType(SoapEnvBody: Text) Response: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        RootXmlElement: XmlElement;
        XmlValues: array[3] of Text;
        ObjectXmlText, EncodedObjectXml : Text;
        TempDT: DateTime;
        OK: Boolean;
        ExpectedRegPeriod: Integer;
    begin
        Response := '-';
        if not GetRootXmlElement(SoapEnvBody, RootXmlElement) then
            Error('No soap envelope body!');
        GetValue(RootXmlElement, '//object', EncodedObjectXml);
        //exit(GenerateHash(EncodedObjectXml));
        //exit(SoapEnvBody);
        ObjectXmlText := Base64Convert.FromBase64(EncodedObjectXml);
        GetRootXmlElement(ObjectXmlText, RootXmlElement);
        GetValue(RootXmlElement, UnitIdX, XmlValues[1]);
        GetValue(RootXmlElement, JoinX(UnitBaseDataX, InvestmentObjectX), XmlValues[2]);
        OK := GetValue(RootXmlElement, JoinX(UnitX, ApartmentOriginTypeX), XmlValues[3]);
        if (XmlValues[2] <> '') or (XmlValues[3] <> '') then begin
            Response := StrSubstNo('%1;%2;%3', XmlValues[1], XmlValues[2], XmlValues[3]);
        end;
    end;

    [TryFunction]
    local procedure GetRootXmlElement(InputXmlText: Text; var RootXmlElement: XmlElement)
    var
        XmlDoc: XmlDocument;
    begin
        TryLoadXml(InputXmlText, XmlDoc);
        XmlDoc.GetRoot(RootXmlElement);
    end;

    [TryFunction]
    local procedure GetValue(XmlElem: XmlElement; xpath: Text; var Value: Text)
    var
        XmlNode: XmlNode;
    begin
        Value := '';
        XmlElem.SelectSingleNode(xpath, XmlNode);
        Value := GetXmlElementText(XmlNode);
    end;


    local procedure JoinX(RootXPath: Text; ChildXPath: Text) Result: Text
    begin
        if not RootXPath.EndsWith('/') then
            RootXPath := RootXPath + '/';
        Result := RootXPath + ChildXPath;
    end;

    [TryFunction]
    local procedure TryLoadXml(XmlText: Text; var XmlDoc: XmlDocument)
    begin
        XmlDocument.ReadFrom(XmlText, XmlDoc);
    end;

    local procedure GetXmlElementText(XmlNode: XmlNode) Result: Text;
    var
        XmlElem: XmlElement;
    begin
        XmlElem := XmlNode.AsXmlElement();
        Result := XmlElem.InnerText;
    end;



}
