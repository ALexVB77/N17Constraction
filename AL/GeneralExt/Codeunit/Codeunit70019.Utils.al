codeunit 70019 "Utils"
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
        JObj: JsonObject;
        JObjLine: JsonObject;
        JArr: JsonArray;
        JArrLines: JsonArray;



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

    procedure Ping(): Text
    var
        tb: TextBuilder;
    begin
        tb.AppendLine('{');
        tb.AppendLine('"field1": "SomeString",');
        tb.AppendLine('"isActive": true');
        tb.AppendLine('}');
        exit(tb.ToText());
    end;

    procedure ConvertObjectXmlToJson(encodedObjectXml: text) Result: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        RootXmlElement: XmlElement;
        XmlValues: array[3] of Text;
        ObjectXmlText, ObjectTypeText : Text;
        TempDT: DateTime;
        OK: Boolean;
        ExpectedRegPeriod: Integer;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        ObjectXmlText := Base64Convert.FromBase64(EncodedObjectXml);
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        //TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(ObjectXmlText);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        //TempBlob.CreateInStream(InStr);
        GetRootXmlElement(InStr, RootXmlElement);
        GetValue(RootXmlElement, ObjectTypeX, ObjectTypeText);
        Result := ObjectXmlToJson(ObjectTypeText, ObjectXmlText);
        Result := Base64Convert.ToBase64(result);
    end;

    local procedure ObjectXmlToJson(ObjectTypeText: Text; ObjectXml: Text) Result: Text
    begin
        case ObjectTypeText.ToUpper() of
            'UNIT':
                Result := UnitXmlToJson(ObjectXml);
            'CONTACT':
                Result := ContactXmlToJson(ObjectXml);
            'CONTRACT':
                Result := ContractXmlToJson(ObjectXml);
        end;
    end;

    local procedure UnitXmlToJson(ObjectXml: Text) Result: Text
    var
        XmlElem: XmlElement;
        XmlBuyer: XmlNode;
        XmlBuyerList: XmlNodeList;
        ElemText, ElemText2, TempValue : Text;
        BuyerNo: Integer;
        ExpectedRegDate, ActualDate, ExpectedDate : Text;
        OK: Boolean;
        TempDec: Decimal;
        TempBool: Boolean;
        TempDate: Date;
        TempDT: DateTime;
        TempInt: Integer;
    begin
        Clear(JObj);
        Clear(JObjLine);
        Clear(JArr);
        Clear(JArrLines);
        GetRootXmlElement(ObjectXml, XmlElem);

        JObj.Add('objectType', 'unit');
        GetValue(XmlElem, JoinX(UnitBaseDataX, ObjectParentIdX), TempValue);
        if TempValue = '' then
            Error('Project Id is not specified');
        JObj.Add('projectId', TempValue);
        GetValue(XmlElem, UnitIdX, TempValue);
        JObj.Add('objectId', TempValue);
        GetValue(XmlElem, JoinX(UnitBaseDataX, ReservingContactX), TempValue);
        JObj.Add('reservingContactId', TempValue);
        GetValue(XmlElem, JoinX(UnitBaseDataX, InvestmentObjectX), TempValue);
        JObj.Add('investmentObjectCode', TempValue);
        OK := GetValue(XmlElem, JoinX(UnitBaseDataX, BlockNumberX), ElemText);
        OK := GetValue(XmlElem, JoinX(UnitBaseDataX, ApartmentNumberX), ElemText2);
        TempValue := ElemText + ' ' + ElemText2;
        TempValue := TempValue.Trim();
        AddJsonField('investmentObjectDescription', TempValue);
        if GetValue(XmlElem, JoinX(UnitX, ApartmentOriginTypeX), TempValue) then
            AddJsonField('investmentObjectType', TempValue);
        if GetValue(XmlElem, JoinX(UnitX, ApartmentUnitAreaM2X), TempValue) then begin
            if Evaluate(TempDec, TempValue) then
                JObj.Add('investmentObjectArea', TempDec);
        end;
        if GetValue(XmlElem, JoinX(UnitX, ExpectedRegDateX), TempValue) then begin
            if Evaluate(TempInt, TempValue, 9) then
                JObj.Add('expectedRegDate', TempInt);
        end;
        if GetValue(XmlElem, JoinX(UnitX, ActualDateX), TempValue) then begin
            if Evaluate(TempDT, TempValue, 9) then
                JObj.Add('actualDate', DT2Date(TempDT));
        end;
        if GetValue(XmlElem, JoinX(UnitX, ExpectedDateX), TempValue) then begin
            if Evaluate(TempDT, TempValue, 9) then
                JObj.Add('expectedDate', DT2Date(TempDT));
        end;
        if XmlElem.SelectNodes(JoinX(UnitX, UnitBuyerNodesX), XmlBuyerList) then begin
            foreach XmlBuyer in XmlBuyerList do begin
                XmlElem := XmlBuyer.AsXmlElement();
                Clear(JObjLine);
                GetValue(XmlElem, UnitBuyerX, TempValue);
                JObjLine.Add('buyerId', TempValue);
                GetValue(XmlElem, UnitBuyerContactX, TempValue);
                JObjLine.Add('contactId', TempValue);
                GetValue(XmlElem, UnitBuyerContractX, TempValue);
                JObjLine.Add('contractId', TempValue);
                if GetValue(XmlElem, UnitBuyerOwnershipPrcX, TempValue) then begin
                    if Evaluate(TempDec, TempValue) then
                        JObjLine.Add('ownershipPrc', TempDec);
                end;
                if GetValue(XmlElem, UnitBuyerIsActiveX, TempValue) then begin
                    if Evaluate(TempBool, TempValue) then
                        JObjLine.Add('buyerIsActive', TempBool);
                end;
                JArrLines.Add(JObjLine);
            end;
            JObj.Add('buyers', JArrLines);
        end;
        JObj.WriteTo(Result)
    end;

    local procedure ContactXmlToJson(ObjectXml: Text) Result: Text
    var
        XmlElem: XmlElement;
        XmlNode: XmlNode;
        XmlNodeList: XmlNodeList;
        OK: Boolean;
        BaseXPath, TempValue : Text;
        ElemText, ElemText2, LastValidPhoneNo, LastValidMailAddress : Text;
        JsonVal: JsonValue;
    begin
        Clear(JObj);

        GetRootXmlElement(ObjectXml, XmlElem);
        BaseXPath := JoinX(ContactX, PersonDataX);

        JObj.Add('objectType', 'contact');
        GetValue(XmlElem, ContactIdX, TempValue);
        AddJsonField('objectId', TempValue);
        GetValue(XmlElem, JoinX(BaseXPath, LastNameX), TempValue);
        AddJsonField('lastName', TempValue);
        GetValue(XmlElem, JoinX(BaseXPath, FirstNameX), TempValue);
        AddJsonField('firstName', TempValue);
        GetValue(XmlElem, JoinX(BaseXPath, MiddleNameX), TempValue);
        AddJsonField('middleName', TempValue);
        BaseXPath := JoinX(ContactX, PhysicalAddressX);
        if XmlNodeExists(XmlElem, BaseXPath) then begin
            ElemText2 := '';
            if GetValue(XmlElem, JoinX(BaseXPath, PostalCityX), TempValue) then
                AddJsonField('postalCity', TempValue);
            if GetValue(XmlElem, JoinX(BaseXPath, CountryCodeX), TempValue) then
                AddJsonField('countryCode', TempValue);
            if GetValue(XmlElem, JoinX(BaseXPath, AddressLineX + '1'), ElemText) then
                ElemText2 := ElemText;
            if GetValue(XmlElem, JoinX(BaseXPath, AddressLineX + '2'), ElemText) then begin
                if ElemText2 <> '' then
                    ElemText2 += ' ';
                ElemText2 += ElemText;
            end;
            if GetValue(XmlElem, JoinX(BaseXPath, AddressLineX + '3'), ElemText) then begin
                if ElemText2 <> '' then
                    ElemText2 += ' ';
                ElemText2 += ElemText;
            end;
            if ElemText2 <> '' then
                AddJsonField('address', ElemText2);
            if GetValue(XmlElem, JoinX(BaseXPath, PostalCodeX), TempValue) then
                AddJsonField('postalCode', TempValue);
        end;

        BaseXPath := JoinX(ContactX, ElectronicAddressesX);
        if not XmlElem.SelectNodes(JoinX(BaseXPath, ElectronicAddressX), XmlNodeList) then
            exit;

        LastValidPhoneNo := '';
        LastValidMailAddress := '';
        foreach XmlNode in XmlNodeList do begin
            XmlElem := XmlNode.AsXmlElement();
            if GetValue(XmlElem, ProtocolX, ElemText) and (ElemText <> '') then begin
                if GetValue(XmlElem, AddressLineX + '1', ElemText2) then begin
                    Case ElemText of
                        ContactPhoneX:
                            begin
                                if ElemText2 <> '' then begin
                                    if CheckValidPhoneNo(ElemText2) then begin
                                        if LastValidPhoneNo <> '' then
                                            LastValidPhoneNo += ';';
                                        LastValidPhoneNo += ElemText2;
                                    end;
                                end;
                            end;
                        ContactEmailX:
                            begin
                                if ElemText2 <> '' then begin
                                    if not CheckValidMailAddress(ElemText2) then begin
                                        if LastValidMailAddress <> '' then
                                            LastValidMailAddress += ';';
                                        LastValidMailAddress += ElemText2;
                                    end;
                                end;
                            end;
                    End
                end;
            end;
        end;

        AddJsonField('phone', LastValidPhoneNo);
        AddJsonField('email', LastValidMailAddress);
        JObj.WriteTo(Result);
    end;

    local procedure ContractXmlToJson(ObjectXml: Text) Result: Text
    var
        TempValue, BuyerList : Text;
        XmlElem: XmlElement;
        XmlBuyer: XmlNode;
        XmlBuyerList: XmlNodeList;
        TempBool: Boolean;
        TempDec: Decimal;
    begin
        Clear(JObj);
        GetRootXmlElement(ObjectXml, XmlElem);
        JObj.Add('objectType', 'contract');
        GetValue(XmlElem, ContractIdX, TempValue);
        AddJsonField('objectId', TempValue);
        GetValue(XmlElem, ContractUnitIdX, TempValue);
        AddJsonField('unitId', TempValue);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ContractNoX), TempValue);
        AddJsonField('number', TempValue);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ContractTypeX), TempValue);
        AddJsonField('type', TempValue);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ContractStatusX), TempValue);
        AddJsonField('status', TempValue);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ContractCancelStatusX), TempValue);
        AddJsonField('cancelStatus', TempValue);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ContractIsActiveX), TempValue);
        if Evaluate(TempBool, TempValue) then
            Jobj.Add('isActive', TempBool);
        GetValue(XmlElem, JoinX(ContractBaseDataX, ExtAgreementNoX), TempValue);
        AddJsonField('externalNo', TempValue);
        GetValue(XmlElem, JoinX(ContractX, AgreementAmountX), TempValue);
        if Evaluate(TempDec, TempValue) then
            JObj.Add('amount', TempDec);
        if GetValue(XmlElem, JoinX(ContractX, FinishingInclX), TempValue) then begin
            if Evaluate(TempBool, TempValue) then
                JObj.Add('finishingIncl', TempBool);
        end;
        if XmlElem.SelectNodes(JoinX(ContractX, ContractBuyerNodesX), XmlBuyerList) then begin
            foreach XmlBuyer in XmlBuyerList do begin
                XmlElem := XmlBuyer.AsXmlElement();
                GetValue(XmlElem, ContractBuyerX, TempValue);
                if BuyerList <> '' then
                    BuyerList += ';';
                BuyerList += TempValue;
            end;
        end;
        AddJsonField('buyers', BuyerList);
        JObj.WriteTo(Result);
    end;

    //=================================================//
    local procedure AddJsonField(FieldName: Text; FieldValue: Text)
    begin
        if FieldValue <> '' then
            JObj.Add(FieldName, FieldValue);
    end;

    //================================================//
    [TryFunction]
    local procedure CheckValidPhoneNo(PhoneNo: Text)
    var
        Char: DotNet Char;
        i: Integer;
    begin
        if PhoneNo = '' then
            exit;

        for i := 1 to StrLen(PhoneNo) do
            if Char.IsLetter(PhoneNo[i]) then
                Error(InvalidPhoneNoErr, PhoneNo);
    end;

    [TryFunction]
    local procedure CheckValidMailAddress(Recipients: Text)
    var
        TmpRecipients: Text;
        IsHandled: Boolean;
        MailMgt: Codeunit "Mail Management";
    begin

        if Recipients = '' then
            exit;

        TmpRecipients := DelChr(Recipients, '<>', ';');
        while StrPos(TmpRecipients, ';') > 1 do begin
            MailMgt.CheckValidEmailAddress(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1));
            TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
        end;
        MailMgt.CheckValidEmailAddress(TmpRecipients);
    end;

    //=== XML ====================================//
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

    [TryFunction]
    local procedure TryLoadXml(InStream: InStream; var XmlDoc: XmlDocument)
    begin
        XmlDocument.ReadFrom(InStream, XmlDoc);
    end;

    local procedure GetXmlElementText(XmlNode: XmlNode) Result: Text;
    var
        XmlElem: XmlElement;
    begin
        XmlElem := XmlNode.AsXmlElement();
        Result := XmlElem.InnerText;
    end;

    [TryFunction]
    local procedure GetRootXmlElement(var InStrm: InStream; var RootXmlElement: XmlElement)
    var
        XmlDoc: XmlDocument;
    begin
        TryLoadXml(InStrm, XmlDoc);
        XmlDoc.GetRoot(RootXmlElement);
    end;

    [TryFunction]
    local procedure XmlNodeExists(XmlElem: XmlElement; XPath: Text)
    var
        TempXmlNode: XmlNode;
    begin
        XmlElem.SelectSingleNode(XPath, TempXmlNode);
    end;

}
