codeunit 99932 "CRM Worker"
{
    TableNo = "Web Request Queue";

    trigger OnRun()
    begin
        Code(Rec);
    end;

    var
        //All
        ObjectTypeX: Label 'Publisher/IntegrationInformation', Locked = true;
        SoapObjectContainerX: Label '//crm_objects/object', Locked = true;
        TargetCompanyNameX: Label '@Target CRM CompanyName', Locked = true;

        CustomerSearchRequest: Label 'CustomerSearchInRequest', Locked = true;
        CustomerSearchDB: Label 'CustomerSearchInDB', Locked = true;
        CustomerSearchFoundNo: Label 'CustomerSearchFoundNo', Locked = true;


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
        ApartmentAmountX: Label 'FinanceData/ContractPrice', Locked = true;
        FinishingInclX: Label 'FinanceData/FullFinishingPrice', Locked = true;
        ContractBuyerNodesX: Label 'Buyers/Buyer', Locked = true;
        ContractBuyerX: Label 'BaseData/ObjectID', Locked = true;

        //Errors
        ContactUnitNotFoundErr: Label 'Unit of Contact or Reserving Contact is not found';
        ContractUnitNotFoundErr: Label 'Unit %1 of Contract is not found';
        ContractNotRegisteredErr: Label 'Contract is not registered, Type %1, Status %2';
        ContractNotSignedErr: Label 'Contract is not signed, Type %1, Status %2';
        ContractBuyersNotFoundErr: Label 'Buyers are not found';
        ContractContactNotFound: Label 'Contact %1 is not found, Parent Object Id (Unit) %2, Buyer %3';
        BadSoapEnvFormatErr: Label 'Bad soap envelope format';
        KeyErr: Label 'No field key is specified!';
        NoObjectIdErr: Label 'No ObjectID in XML Document';
        NoParentObjectIdErr: Label 'No ParentObjectID in XML Document';
        ProjectNotFoundErr: Label 'ProjectId %1 is not found in %2';
        UnknownObjectTypeErr: Label 'Unknown type of Object %1';
        NoParsedDataOnImportErr: Label 'Import of object %1 interrupted. No parsed data';
        FieldNameDoesNotExistErr: label 'Object field name %1 does not exist';
        AgrMustBeTemporaryErr: Label 'Customer Agrement record must be temporary';


        //Messages
        ContactUpToDateMsg: Label 'Customer No. %1 is up to date';
        ContactProcessedMsg: Label 'Customer No. %1';
        EmptyHttpRequestBody: Label 'Http request body is empty';
        NoInvestObjectMsg: Label 'Investment object is not specified';
        InvestmentObjectCreatedMsg: label 'Investment object %1 was created';
        InvestmentObjectUpdatedMsg: label 'Investment object %1 was updated';
        UnitCreatedMsg: Label 'Unit was created';
        UnitUpdatedMsg: Label 'Unit was updated';
        UnitUpToDateMsg: label 'Unit is up to date';

        //==
        ObjectDataElementPointer: Dictionary of [Text, Text];

    procedure ImportObjects(var FetchedObject: Record "CRM Prefetched Object")
    var
        AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        CrmInteractCompanies: List of [Text];
        TargetCompany: Text[60];
        ImportAction: Enum "CRM Import Action";
        Updated: Boolean;
    begin

        ParseObjects(FetchedObject, AllObjectData);


        if AllObjectData.Count() = 0 then
            exit;

        //create/update units
        FetchedObject.SetRange(Type, FetchedObject.Type::Unit);
        if FetchedObject.FindSet() then begin
            repeat
                ImportUnit(FetchedObject, AllObjectData);
            until FetchedObject.Next() = 0;
            FetchedObject.DeleteAll(true);
        end;

        // update contacts
        GetCrmInteractCompanyList(CrmInteractCompanies);
        FetchedObject.SetRange(Type, FetchedObject.Type::Contact);
        if FetchedObject.FindSet() then begin
            repeat
                Updated := false;
                foreach TargetCompany in CrmInteractCompanies do begin
                    ImportAction := GetObjectImportAction(FetchedObject, TargetCompany);
                    if ImportAction = ImportAction::Update then begin
                        Updated := true;
                        ImportContact(FetchedObject, AllObjectData, TargetCompany, ImportAction);
                    end;
                end;
                if Updated then
                    FetchedObject.Delete();
            until FetchedObject.Next() = 0;
        end;

        FetchedObject.SetRange(Type, FetchedObject.Type::Contract);
        if FetchedObject.FindSet() then begin
            repeat
            //ImportContract(FetchedObject, AllObjectData);
            until FetchedObject.Next() = 0;
        end;
        FetchedObject.DeleteAll(true)

    end;

    local procedure Code(var WebRequestQueue: Record "Web Request Queue")
    var
        FetchedObjectBuff: Record "CRM Prefetched Object" temporary;
        FetchedObject: Record "CRM Prefetched Object";
        AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
    begin
        PickupPrefetchedObjects(FetchedObjectBuff);
        if not FetchObjects(WebRequestQueue, FetchedObjectBuff) then
            exit;

        ParseObjects(FetchedObjectBuff, AllObjectData);
        SetTargetCompany(FetchedObjectBuff, AllObjectData);
        FetchedObjectBuff.Reset();
        if not FetchedObjectBuff.FindSet() then
            exit;
        repeat
            FetchedObjectBuff.CalcFields(Xml);
            FetchedObject := FetchedObjectBuff;
            if not FetchedObject.Insert(true) then
                FetchedObject.Modify(true);
        until FetchedObjectBuff.Next() = 0;
    end;

    local procedure CreateObjDataElement(var ObjList: List of [Dictionary of [Text, Text]]; var NewElement: Dictionary of [Text, Text])
    var
        SomeDict: Dictionary of [Text, Text];
    begin
        NewElement := SomeDict;
        ObjList.Add(NewElement);
    end;

    [TryFunction]
    local procedure DGet(TKey: Text; var TValue: Text)
    begin
        TValue := '';
        if not ObjectDataElementPointer.Get(TKey, TValue) then begin
            Error(FieldNameDoesNotExistErr, TKey);
        end;

    end;

    local procedure FetchObjects(var WRQ: Record "Web Request Queue"; var TempFetchedObject: Record "CRM Prefetched Object") Result: Boolean
    var
        XmlCrmObjectList: XmlNodeList;
        RootXmlElement: XmlElement;
        XmlCrmObject: XmlNode;
        RequestBodyXmlText, ObjXmlBase64, TempValue : text;
        LogStatusEnum: Enum "CRM Log Status";
        ObjectMetadata: Dictionary of [Text, Text];
        OutStrm: OutStream;
        InStrm: InStream;
        UnitToProjectMap: Dictionary of [Guid, Guid];
        ContactToUnitsMap: Dictionary of [Guid, List of [Guid]];
        ContractToUnitMap: Dictionary of [Guid, Guid];
    begin
        Result := false;
        Clear(ObjectMetadata);
        ObjectMetadata.Add(TempFetchedObject.FieldName("WRQ Id"), WRQ.Id);
        ObjectMetadata.Add(TempFetchedObject.FieldName("WRQ Source Company Name"), CompanyName());
        WRQ.CalcFields("Request Body");
        if not WRQ."Request Body".HasValue() then begin
            LogEvent(ObjectMetadata, EmptyHttpRequestBody);
            exit;
        end;
        WRQ."Request Body".CreateInStream(InStrm, TextEncoding::UTF8);
        InStrm.Read(RequestBodyXmlText);

        TempFetchedObject.Reset();
        TempFetchedObject.DeleteAll();
        if not GetRootXmlElement(RequestBodyXmlText, RootXmlElement) then begin
            LogEvent(ObjectMetadata, GetLastErrorText());
            exit;
        end;
        if not RootXmlElement.SelectNodes(SoapObjectContainerX, XmlCrmObjectList) then begin
            LogEvent(ObjectMetadata, BadSoapEnvFormatErr);
            exit;
        end;
        foreach XmlCrmObject in XmlCrmObjectList do begin
            Clear(ObjectMetadata);
            ObjectMetadata.Add(TempFetchedObject.FieldName("WRQ Id"), WRQ.Id);
            ObjectMetadata.Add(TempFetchedObject.FieldName("WRQ Source Company Name"), CompanyName());
            ObjXmlBase64 := GetXmlElementText(XmlCrmObject);
            if not GetObjectMetadata(ObjXmlBase64, ObjectMetadata) then
                LogEvent(ObjectMetadata, GetLastErrorText())
            else begin
                Result := true;
                TempFetchedObject.Init();
                ObjectMetadata.Get(TempFetchedObject.FieldName(Id), TempValue);
                Evaluate(TempFetchedObject.Id, TempValue);
                ObjectMetadata.Get(TempFetchedObject.FieldName(Type), TempValue);
                Evaluate(TempFetchedObject.Type, TempValue);
                if ObjectMetadata.Get(TempFetchedObject.FieldName(ParentId), TempValue) then
                    Evaluate(TempFetchedObject.ParentId, TempValue);
                ObjectMetadata.Get(TempFetchedObject.FieldName(Xml), TempValue);
                TempFetchedObject.Xml.CreateOutStream(OutStrm, TextEncoding::UTF8);
                OutStrm.WriteText(TempValue);
                ObjectMetadata.Get(TempFetchedObject.FieldName("Version Id"), TempFetchedObject."Version Id");
                TempFetchedObject."WRQ Id" := WRQ.id;
                TempFetchedObject."WRQ Source Company Name" := CompanyName();
                TempFetchedObject."Prefetch Datetime" := CurrentDateTime();
                if not TempFetchedObject.Insert() then
                    TempFetchedObject.Modify();
            end;
        end;
    end;

    local procedure fff(): enum "CRM IMport Action"
    begin

    end;

    local procedure GenerateHash(InputText: Text) Hash: Text[40]
    var
        CM: Codeunit "Cryptography Management";
    begin
        exit(CopyStr(CM.GenerateHash(InputText, 1), 1, 40)); //SHA1
    end;

    local procedure GetAgrStatus(CrmAgrStatus: Text[100]; CrmAgrCancelStatus: Text[100]) Result: Integer
    var
        CustAgr: record "Customer Agreement" temporary;
    begin
        Result := 0;
        if CrmAgrStatus = '' then
            exit;
        CrmAgrStatus := CrmAgrStatus.ToUpper();
        CrmAgrCancelStatus := CrmAgrCancelStatus.ToUpper();
        case true of
            CrmAgrStatus.Contains('DRAFT'):
                Result := CustAgr.Status::Procesed;
            CrmAgrStatus.Contains('REGISTERED_RU'):
                Result := CustAgr.Status::"FRS registered";
            CrmAgrStatus.Contains('SIGNED'):
                Result := CustAgr.Status::Signed;
            CrmAgrStatus.Contains('SUBMITTED'):
                Result := CustAgr.Status::"FRS registration";
            CrmAgrStatus.Contains('REGISTRED'):
                Result := CustAgr.Status::"FRS registered";
            CrmAgrStatus.Contains('CANCELED'):
                begin
                    case true of
                        CrmAgrCancelStatus.Contains('CANCELED'):
                            Result := CustAgr.Status::Annulled;
                        CrmAgrCancelStatus.Contains('SUBMITTED'):
                            Result := CustAgr.Status::"Registration of annulled";
                        CrmAgrCancelStatus.Contains('REGISTRED'):
                            Result := CustAgr.Status::"Annulled registered";
                        else
                            Result := CustAgr.Status::Annulled;
                    end;
                end;
            CrmAgrStatus.Contains('CONVERTED_RU'):
                Result := CustAgr.Status::Cancelled;
            CrmAgrStatus.Contains('CONVERTED'):
                Result := CustAgr.Status::Annulled;
        end;
    end;

    local procedure GetAgrType(CrmAgrType: text[250]) Result: Integer;
    var
        CustAgr: record "Customer Agreement";
    begin
        Result := 0;
        if CrmAgrType = '' then
            exit;
        CrmAgrType := CrmAgrType.ToUpper();
        case true of
            CrmAgrType.Contains('INVESTMENTCONTRACT'):
                result := CustAgr."Agreement Type"::"Investment Agreement";
            CrmAgrType.Contains('PRELIMINARYSALESCONTRACT'):
                result := CustAgr."Agreement Type"::"Prev Inv. Sales Agreement";
            CrmAgrType.Contains('SALESCONTRACT'):
                result := CustAgr."Agreement Type"::"Inv. Sales Agreement";
            CrmAgrType.Contains('SIGNEDRESERVATION'):
                result := CustAgr."Agreement Type"::"Reserving Agreement";
            CrmAgrType.Contains('TRANSFEROFRIGHTS'):
                result := CustAgr."Agreement Type"::"Transfer of rights";
        end;
    end;

    local procedure GetContactFromCustomer(CustomerNo: Code[20]) Result: Code[20]
    var
        ContBusRel: Record "Contact Business Relation";
        Cont: Record Contact;
    begin
        Result := '';
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", CustomerNo);
        if ContBusRel.FindFirst() then
            Result := ContBusRel."Contact No.";
    end;

    local procedure GetCrmInteractCompanyList(var CrmInteractCompanyList: List of [Text])
    var
        CrmCompany: Record "CRM Company";
    begin
        Clear(CrmInteractCompanyList);
        CrmCompany.Reset();
        CrmCompany.FindSet();
        repeat
            if CrmCompany."Company Name" <> '' then begin
                if not CrmInteractCompanyList.Contains(CrmCompany."Company Name") then
                    CrmInteractCompanyList.Add(CrmCompany."Company Name");
            end;
        until CrmCompany.Next() = 0;
    end;

    [TryFunction]
    local procedure GetObjectField(XmlElem: XmlElement; Xpath: Text; var ObjDataContainer: Dictionary of [Text, Text]; FieldKey: Text)
    var
        TempXmlElemValue: Text;
        TempValue: Text;
    begin
        GetValue(XmlElem, xpath, TempXmlElemValue);
        if FieldKey = '' then
            Error(KeyErr);
        if ObjDataContainer.Get(FieldKey, TempValue) then
            Error('KeyError %1 already exists', FieldKey);
        ObjDataContainer.Add(FieldKey, TempXmlElemValue);
    end;

    local procedure GetObjectImportAction(FetchedObject: record "CRM Prefetched Object") Result: Enum "CRM Import Action"
    begin
        Result := GetObjectImportAction(FetchedObject, '');
    end;

    local procedure GetObjectImportAction(FetchedObject: record "CRM Prefetched Object"; ForCompany: Text[60]) Result: Enum "CRM Import Action"
    var
        Cust: Record Customer;
        Agr: Record "Customer Agreement";
        CRMB: Record "CRM Buyers";
    begin
        case FetchedObject.Type of
            FetchedObject.Type::Unit:
                begin
                    CRMB.Reset();
                    if (ForCompany <> '') and (ForCompany <> CompanyName()) then
                        CRMB.ChangeCompany(ForCompany);
                    CRMB.SetRange("Unit Guid", FetchedObject.Id);
                    if CRMB.IsEmpty then
                        Result := Result::Create
                    else begin
                        CRMB.SetRange("Version Id", FetchedObject."Version Id");
                        if CRMB.IsEmpty then
                            Result := Result::Update
                        else
                            Result := Result::NoAction;
                    end;
                end;

            FetchedObject.Type::Contact:
                begin
                    Cust.Reset();
                    if (ForCompany <> '') and (ForCompany <> CompanyName()) then
                        Cust.ChangeCompany(ForCompany);
                    Cust.Setrange("CRM GUID", FetchedObject.Id);
                    if Cust.IsEmpty() then
                        Result := Result::Create
                    else begin
                        Cust.SetRange("Version Id", FetchedObject."Version Id");
                        if Cust.IsEmpty() then
                            Result := Result::Update
                        else
                            Result := Result::NoAction;
                    end;
                end;

            FetchedObject.Type::Contract:
                begin
                    Agr.Reset();
                    if (ForCompany <> '') and (ForCompany <> CompanyName()) then
                        Agr.ChangeCompany(ForCompany);
                    Agr.SetRange("CRM GUID", FetchedObject.Id);
                    if Agr.IsEmpty() then
                        Result := Result::Create
                    else begin
                        Agr.SetRange("Version Id", FetchedObject."Version Id");
                        if Agr.IsEmpty() then
                            Result := Result::Update
                        else begin
                            Result := Result::NoAction;
                        end;
                    end;
                end;
        end
    end;

    [TryFunction]
    local procedure GetObjectMetadata(Base64EncodedObjectXml: Text; var NewObjectMetadata: Dictionary of [Text, Text])
    var
        Base64Convert: Codeunit "Base64 Convert";
        XmlDoc: XmlDocument;
        RootXmlElement: XmlElement;
        ObjectXmlText, ObjectType, ObjectIdText, ParentObjectIdText : Text;
        OutStrm: OutStream;
        T: Record "CRM Prefetched Object" temporary;
    begin
        ObjectXmlText := Base64Convert.FromBase64(Base64EncodedObjectXml);
        NewObjectMetadata.Add(T.FieldName(Xml), ObjectXmlText);
        NewObjectMetadata.Add(T.FieldName("Version Id"), GenerateHash(ObjectXmlText));
        GetRootXmlElement(ObjectXmlText, RootXmlElement);
        GetValue(RootXmlElement, ObjectTypeX, ObjectType);
        case UpperCase(ObjectType) of
            'UNIT':
                begin
                    GetValue(RootXmlElement, UnitIdX, ObjectIdText);
                    GetValue(RootXmlElement, UnitProjectIdX, ParentObjectIdText);
                end;
            'CONTACT':
                GetValue(RootXmlElement, ContactIdX, ObjectIdText);
            'CONTRACT':
                begin
                    GetValue(RootXmlElement, ContractIdX, ObjectIdText);
                    GetValue(RootXmlElement, ContractUnitIdX, ParentObjectIdText);
                end;
            else
                Error(UnknownObjectTypeErr, ObjectType);
        end;
        NewObjectMetadata.Add(T.FieldName(id), ObjectIdText);
        NewObjectMetadata.Add(T.FieldName(Type), ObjectType);
        if ParentObjectIdText <> '' then
            NewObjectMetadata.Add(T.FieldName(ParentId), ParentObjectIdText);
        if ObjectIdText = '' then
            Error(NoObjectIdErr);
        if (UpperCase(ObjectType) in ['CONTRACT', 'UNIT']) and (ParentObjectIdText = '') then
            Error(NoParentObjectIdErr);

    end;


    [TryFunction]
    local procedure GetRootXmlElement(var FetchedObject: record "CRM Prefetched Object"; var RootXmlElement: XmlElement)
    var
        InStrm: InStream;
        XmlDoc: XmlDocument;
    begin
        FetchedObject.CalcFields(Xml);
        FetchedObject.Testfield(xml);
        FetchedObject.Xml.CreateInStream(InStrm, TextEncoding::UTF8);
        TryLoadXml(InStrm, XmlDoc);
        XmlDoc.GetRoot(RootXmlElement);
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
    local procedure GetTargetCrmCompany(var FetchedObject: Record "CRM Prefetched Object"; SearchInCrmInteractCompanyList: List of [Text]; var TargetCompanyName: Text)
    var
        CrmCompany: Record "CRM Company";
        CrmB: Record "CRM Buyers";
        CrmCompanyName: Text;
    begin
        TargetCompanyName := '';
        case FetchedObject.Type of
            FetchedObject.Type::Unit:
                begin
                    CrmCompany.SetRange("Project Guid", FetchedObject.ParentId);
                    if not CrmCompany.FindFirst() then
                        Error(ProjectNotFoundErr, FetchedObject.ParentId, CrmCompany.TableCaption)
                    else begin
                        CrmCompany.TestField("Company Name");
                        TargetCompanyName := CrmCompany."Company Name";
                    end;
                end;
            FetchedObject.Type::Contract:
                begin
                    foreach CrmCompanyname in SearchInCrmInteractCompanyList do begin
                        CrmB.ChangeCompany(CrmCompanyName);
                        CrmB.SetRange("Unit Guid", FetchedObject.ParentId);
                        if CrmB.FindFirst() then begin
                            TargetCompanyName := CrmCompanyName;
                            break;
                        end;
                    end;
                    if TargetCompanyName = '' then
                        Error(ContractUnitNotFoundErr, FetchedObject.ParentId);
                end;
            FetchedObject.Type::Contact:
                begin
                    foreach CrmCompanyname in SearchInCrmInteractCompanyList do begin
                        CrmB.Reset();
                        CrmB.ChangeCompany(CrmCompanyName);
                        CrmB.SetRange("Contact Guid", FetchedObject.Id);
                        if CrmB.FindFirst() then begin
                            TargetCompanyName := CrmCompanyName;
                            break;
                        end;
                        CrmB.SetRange("Contact Guid");
                        CrmB.SetRange("Reserving Contact Guid", FetchedObject.Id);
                        if CrmB.FindFirst() then begin
                            TargetCompanyName := CrmCompanyName;
                            break;
                        end;
                    end;
                    if TargetCompanyName = '' then
                        Error(ContactUnitNotFoundErr);
                end;
        end
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

    local procedure GetXmlElementText(XmlNode: XmlNode) Result: Text;
    var
        XmlElem: XmlElement;
    begin
        XmlElem := XmlNode.AsXmlElement();
        Result := XmlElem.InnerText;
    end;

    local procedure ImportContact(var FetchedObject: Record "CRM Prefetched Object";
        AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        TargetCompanyName: Text[60];
        RequiredImportAction: Enum "CRM Import Action") Result: Code[20]
    var
        Customer: Record Customer;
        CustTemp: Record Customer temporary;
        CrmSetup: Record "CRM Integration Setup";
        UpdateContFromCust: Codeunit "CustCont-Update";
        ContBusRelation: Record "Contact Business Relation";
        Value: Text;
        TempStr: Text;
        TempDT: DateTime;
        LogStatusEnum: Enum "CRM Log Status";
        ObjectData: List of [Dictionary of [Text, Text]];
        ObjDataElement: Dictionary of [Text, Text];
    begin

        if AllObjectData.Count = 0 then
            exit;

        if not AllObjectData.Get(FetchedObject.Id, ObjectData) then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(NoParsedDataOnImportErr, FetchedObject.Id));
            exit;
        end;

        ObjDataElement := ObjectData.Get(1);

        if (RequiredImportAction = RequiredImportAction::Create) and (TargetCompanyName <> '') and (TargetCompanyName <> CompanyName()) then
            Error('Contact creating error!');

        if (TargetCompanyName <> CompanyName()) and (TargetCompanyName <> '') then begin
            Customer.ChangeCompany(TargetCompanyName);
            CrmSetup.ChangeCompany(TargetCompanyName);
            ContBusRelation.ChangeCompany(TargetCompanyName);
        end;

        CustTemp.Init();
        ObjDataElement.Get(LastNameX, Value);
        TempStr := Value;
        ObjDataElement.Get(FirstNameX, Value);
        TempStr += ' ' + Value;
        ObjDataElement.Get(MiddleNameX, Value);
        TempStr += ' ' + Value;
        CustTemp.Name := CopyStr(TempStr, 1, MaxStrLen(CustTemp.Name));
        if MaxStrLen(CustTemp.Name) < StrLen(TempStr) then
            CustTemp."Name 2" := CopyStr(TempStr, MaxStrLen(CustTemp.Name) + 1, MaxStrLen(CustTemp."Name 2"));
        TempStr := '';
        if ObjDataElement.Get(PostalCityX, Value) then
            CustTemp.City := CopyStr(Value, 1, MaxStrLen(CustTemp.City));
        if ObjDataElement.Get(CountryCodeX, Value) then
            CustTemp."Country/Region Code" := CopyStr(Value, 1, MaxStrLen(CustTemp."Country/Region Code"));
        if ObjDataElement.Get(PostalCodeX, Value) then
            CustTemp."Post Code" := CopyStr(Value, 1, MaxStrLen(CustTemp."Post Code"));
        TempStr := '';
        if ObjDataElement.Get(AddressLineX, Value) then
            TempStr := Value;
        TempStr := TempStr + StrSubstNo(' ,%1, %2', CustTemp.City, CustTemp."Country/Region Code");
        CustTemp.Address := CopyStr(TempStr, 1, MaxStrLen(CustTemp.Address));
        If MaxStrLen(CustTemp.Address) < StrLen(TempStr) then
            CustTemp."Address 2" := CopyStr(TempStr, MaxStrLen(CustTemp.Address) + 1, MaxStrLen(CustTemp."Address 2"));
        if ObjDataElement.Get(ContactPhoneX, Value) then
            CustTemp."Phone No." := CopyStr(Value, 1, MaxStrLen(CustTemp."Phone No."));
        if ObjDataElement.Get(ContactEmailX, Value) then
            CustTemp."E-Mail" := CopyStr(Value, 1, MaxStrLen(CustTemp."E-Mail"));

        Customer.Reset();
        case RequiredImportAction of
            RequiredImportAction::Create:
                begin
                    Customer.Init();
                    Customer."No." := '';
                    Customer.Insert(true);
                end;
            RequiredImportAction::Update:
                begin
                    Customer.SetRange("CRM GUID", FetchedObject.id);
                    Customer.SetRange("Version Id");
                    Customer.FindFirst();
                end;
            else
                exit;
        end;
        Result := Customer."No.";

        Customer.Validate(Name, CustTemp.Name);
        Customer.Validate("Name 2", CustTemp."Name 2");
        Customer.Validate(City, CustTemp.City);
        Customer.Validate("Country/Region Code", CustTemp."Country/Region Code");
        Customer.Validate("Post Code", CustTemp."Post Code");
        Customer.Validate(Address, CustTemp.Address);
        Customer.Validate("Address 2", CustTemp."Address 2");
        Customer.Validate("Phone No.", CustTemp."Phone No.");
        Customer.Validate("E-Mail", CustTemp."E-Mail");
        Customer."Version Id" := FetchedObject."Version Id";
        if RequiredImportAction = RequiredImportAction::Create then begin
            Customer."CRM GUID" := FetchedObject.Id;
            Customer.Validate("Agreement Posting", Customer."Agreement Posting"::Mandatory);
            CrmSetup.Get;
            if Customer."Customer Posting Group" = '' then
                Customer.Validate("Customer Posting Group", CrmSetup."Customer Posting Group");
            if Customer."Gen. Bus. Posting Group" = '' then
                Customer.Validate("Gen. Bus. Posting Group", CrmSetup."Gen. Bus. Posting Group");
            if Customer."VAT Bus. Posting Group" = '' then
                Customer.Validate("VAT Bus. Posting Group", CrmSetup."VAT Bus. Posting Group");
            ContBusRelation.SETCURRENTKEY("Link to Table", "No.");
            ContBusRelation.SetRange("Link to Table", ContBusRelation."Link to Table"::Customer);
            ContBusRelation.SetRange("No.", Customer."No.");
            IF NOT ContBusRelation.FindFirst() THEN BEGIN
                UpdateContFromCust.InsertNewContact(Customer, FALSE);
            END;
        end;
        Customer.Modify(true);

        LogEvent(FetchedObject, TargetCompanyName, LogStatusEnum::Done, RequiredImportAction, StrSubstNo(ContactProcessedMsg, Customer."No."), '');
        Commit();
    end;

    [TryFunction]
    local procedure ImportContract(var FetchedObject: Record "CRM Prefetched Object";
        AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        CrmInteractCompanies: List of [Text];
        var AgrTemp: Record "Customer Agreement";
        var Customers: Dictionary of [Integer, Dictionary of [Text, Text]]
    )
    var
        Agr: Record "Customer Agreement";
        LogStatusEnum: Enum "CRM Log Status";
        ImportActionEnum: Enum "CRM Import Action";
        ObjectData, ContactData : List of [Dictionary of [Text, Text]];
        ObjDataElement: Dictionary of [Text, Text];
        I, C, ShareHolderNo : Integer;
        TempValue, TempValue2 : Text;
        OK: Boolean;
        UnitId, BuyerId, ContactId : Guid;
        CrmB: Record "CRM Buyers";
        Cust: Record Customer;
        NewCustomerNo: Code[20];
        FObj: Record "CRM Prefetched Object";
        CustNo, NavContactNo : Code[20];

    begin
        if not AgrTemp.IsTemporary then
            Error(AgrMustBeTemporaryErr);

        if AllObjectData.Count = 0 then
            Error('DBG: No parsed data');


        if not AllObjectData.Get(FetchedObject.Id, ObjectData) then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(NoParsedDataOnImportErr, FetchedObject.Id));
            exit;
        end;

        SetObjectDataElementPointer(ObjectData, 1);
        AgrTemp.Init;
        DGet(ContractIdX, TempValue);
        Evaluate(AgrTemp."CRM GUID", TempValue);
        DGet(ContractNoX, TempValue);
        AgrTemp.Description := CopyStr(TempValue, 1, MaxStrLen(AgrTemp.Description));
        DGet(ContractTypeX, TempValue);
        AgrTemp."Agreement Type" := GetAgrType(TempValue);
        DGet(ContractStatusX, TempValue);
        DGet(ContractCancelStatusX, TempValue2);
        AgrTemp.Status := GetAgrStatus(TempValue, TempValue2);
        DGet(ContractIsActiveX, TempValue);
        if (TempValue = 'false') or (AgrTemp.Status = AgrTemp.Status::Cancelled) then
            AgrTemp.Active := false
        else
            AgrTemp.Active := true;

        DGet(ExtAgreementNoX, TempValue);
        AgrTemp."External Agreement No." := CopyStr(TempValue, 1, MaxStrLen(AgrTemp."External Agreement No."));
        //FullAgreementNo to-do
        DGet(ApartmentAmountX, TempValue);
        OK := Evaluate(AgrTemp."Agreement Amount", TempValue, 9);
        if DGet(FinishingInclX, TempValue) then begin
            Ok := Evaluate(AgrTemp."Including Finishing Price", TempValue, 9);
        end;

        DGet(ContractUnitIdX, TempValue);
        Evaluate(UnitId, TempValue);

        C := ObjectData.Count;
        if (C = 1) and (AgrTemp."Agreement Type" <> AgrTemp."Agreement Type"::"Reserving Agreement") then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, ContractBuyersNotFoundErr);
            exit;
        end;
        if (C = 1) or (AgrTemp."Agreement Type" = AgrTemp."Agreement Type"::"Reserving Agreement") then begin
            CrmB.SetRange("Unit Guid", UnitId);
            if not CrmB.FindFirst() then begin
                LogEvent(FetchedObject, LogStatusEnum::Error, ContractBuyersNotFoundErr);
            end else begin
                CrmB."Reserving Contract Guid" := AgrTemp."CRM GUID";
                CrmB.Modify();
                AgrTemp."Object of Investing" := CrmB."Object of Investing";
                CustNo := FindCustomer(CrmB."Reserving Contact Guid", 0, AllObjectData, CrmInteractCompanies, Customers);
                if CustNo = '' then
                    LogEvent(FetchedObject, LogStatusEnum::Error, ContractBuyersNotFoundErr)
                else begin
                    SetShareholderAttributes(AgrTemp, 1, CustNo, GetContactFromCustomer(CustNo), CrmB."Ownership Percentage");
                    if CrmB."Agreement Start" <> 0D then begin
                        AgrTemp."Agreement Date" := CrmB."Agreement Start";
                        AgrTemp."Starting Date" := CrmB."Agreement Start";
                        AgrTemp."Expire Date" := CrmB."Agreement End";
                    end;
                end;
            end;
            exit;
        end;

        ShareHolderNo := 0;
        for I := 2 to C do begin
            ObjDataElement := ObjectData.Get(I);
            ObjDataElement.Get(ContractBuyerX, TempValue);
            Evaluate(BuyerId, TempValue);
            CrmB.Get(UnitId, BuyerId);
            if CrmB."Buyer Is Active" then begin
                ShareHolderNo += 1;
                AgrTemp."Object of Investing" := CrmB."Object of Investing";
                if CrmB."Agreement Start" <> 0D then begin
                    AgrTemp."Agreement Date" := CrmB."Agreement Start";
                    AgrTemp."Starting Date" := CrmB."Agreement Start";
                    AgrTemp."Expire Date" := CrmB."Agreement End";
                end;
                ContactId := CrmB."Contact Guid";
                CustNo := FindCustomer(ContactId, ShareHolderNo, AllObjectData, CrmInteractCompanies, Customers);
                if CustNo <> '' then
                    NavContactNo := GetContactFromCustomer(CustNo)
                else begin
                    CustNo := Format(ShareHolderNo);
                    NavContactNo := CustNo;
                end;
                SetShareholderAttributes(AgrTemp, ShareHolderNo, CustNo, NavContactNo, CrmB."Ownership Percentage")
            end;
            if ShareHolderNo = 5 then
                break;
        end;
    end;

    local procedure CreateContractAndLinkedContacts(var FetchedObject: Record "CRM Prefetched Object";
        var PrefilledAgrTemp: Record "Customer Agreement";
        var Customers: Dictionary of [Integer, Dictionary of [Text, Text]])
    var
        int: Integer;
        CustomerSearchInfo: Dictionary of [Text, Text];
        NotFoundShareHolderList: List of [Integer];
        ShareHolderNo: Integer;
    begin
        NotFoundShareHolderList := Customers.Keys();
        foreach ShareholderNo in NotFoundShareHolderList do begin


        end;

    end;

    local procedure CopyCustomer(CrmContactId: Guid; CopyFromCompanyName: Text[60]; CopyFromCustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if IsNullGuid(CrmContactId) then
            Error('DBG: CopyCustomer - CrmContactId is null');
        Customer.Reset();
        Customer.Setrange("CRM GUID", CrmContactId);
        if Not Customer.IsEmpty then
            Error('DBG: CopyCustomer - Customer with id %1 already exists in Company %2', CrmContactId, CompanyName());

        if CopyFromCompanyName = '' then
            Error('DBG: CopyCustomer - CopyFromCompanyName is empty');

        Customer.ChangeCompany(CopyFromCompanyName);
        Customer.Get(CopyFromCustomerNo);


    end;

    local procedure FindCustomer(ContactId: Guid;
        ShareHolderNo: Integer;
        AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        CrmInteractCompanies: List of [Text];
        var Customers: Dictionary of [Integer, Dictionary of [Text, Text]]
        ) ActualCustomerNo: Code[20]
    var
        myInt: Integer;
        ObjectDataElements: List of [Dictionary of [Text, Text]];
        TempDict: Dictionary of [Text, Text];
        Cust: Record Customer;
        SearchInCompanyName: Text;
    begin
        ActualCustomerNo := '';
        if AllObjectData.Get(ContactId, ObjectDataElements) then begin
            TempDict.Add(CustomerSearchRequest, Format(ContactId));
            Customers.Add(ShareHolderNo, TempDict);
            exit;
        end;

        Cust.Reset();
        Cust.SetRange("CRM GUID", ContactId);
        if Cust.FindFirst() then begin
            ActualCustomerNo := Cust."No.";
            exit;
        end;

        foreach SearchInCompanyName in CrmInteractCompanies do begin
            if SearchInCompanyName <> CompanyName() then begin
                Cust.Reset();
                Cust.ChangeCompany(SearchInCompanyName);
                Cust.SetRange("CRM GUID", ContactId);
                if Cust.FindFirst() then begin
                    TempDict.Add(CustomerSearchDB, SearchInCompanyName);
                    TempDict.Add(CustomerSearchFoundNo, Cust."No.");
                    Customers.Add(ShareHolderNo, TempDict);
                    exit;
                end;
            end;
        end;

    end;

    local procedure ImportUnit(var FetchedObject: Record "CRM Prefetched Object"; AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]])
    var
        CRMBuyer: Record "CRM Buyers";
        Apartments: Record Apartments;
        Value, TargetCompanyName : Text;
        TempDT: DateTime;
        No: Text[2];
        LogStatusEnum: Enum "CRM Log Status";
        ImportAction: Enum "CRM Import Action";

        ObjectData: List of [Dictionary of [Text, Text]];
        ObjDataElement: Dictionary of [Text, Text];
        I, C : integer;

    begin
        if AllObjectData.Count = 0 then
            exit;

        if not AllObjectData.Get(FetchedObject.Id, ObjectData) then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(NoParsedDataOnImportErr, FetchedObject.Id));
            exit;
        end;

        ImportAction := GetObjectImportAction(FetchedObject);
        If ImportAction = ImportAction::NoAction then begin
            LogEvent(FetchedObject, LogStatusEnum::Done, UnitUpToDateMsg);
            exit;
        end;

        ObjDataElement := ObjectData.Get(1);

        CRMBuyer.Reset();
        CRMBuyer.SetRange("Unit Guid", FetchedObject.Id);
        CRMBuyer.DeleteAll(true);

        CRMBuyer.Init();
        CRMBuyer."Unit Guid" := FetchedObject.Id;
        CRMBuyer."Version Id" := FetchedObject."Version Id";
        CRMBuyer."Project Id" := FetchedObject.ParentId;
        if ObjDataElement.Get(ReservingContactX, Value) then
            Evaluate(CRMBuyer."Reserving Contact Guid", Value);
        if not ObjDataElement.Get(InvestmentObjectX, Value) then
            LogEvent(FetchedObject, LogStatusEnum::Warning, NoInvestObjectMsg)
        else begin
            CRMBuyer."Object of Investing" := Value;
            Apartments."Object No." := CRMBuyer."Object of Investing";
            if ObjDataElement.Get(BlockNumberX, Value) then
                Apartments.Description := Value.Trim();
            if ObjDataElement.Get(ApartmentNumberX, Value) then begin
                if (Apartments.Description <> '') and (not Apartments.Description.EndsWith(' ')) then
                    Apartments.Description += ' ';
                Apartments.Description += Value.Trim();
            end;
            if ObjDataElement.Get(ApartmentOriginTypeX, Value) then
                Apartments."Origin Type" := CopyStr(Format(Value), 1, MaxStrLen(Apartments."Origin Type"));
            if ObjDataElement.Get(ApartmentUnitAreaM2X, Value) then
                if Evaluate(Apartments."Total Area (Project)", Value, 9) then;
            if Apartments.Insert(True) then begin
                LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(InvestmentObjectCreatedMsg, Apartments."Object No."));
            end else begin
                Apartments.Modify(True);
                LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(InvestmentObjectUpdatedMsg, Apartments."Object No."));
            end;
        end;

        C := ObjectData.Count();
        if C = 1 then begin
            CRMBuyer.Insert(true);
            Commit();
            LogEvent(FetchedObject, LogStatusEnum::Done, UnitCreatedMsg);
            exit;
        end;

        for I := 2 to C do begin
            ObjDataElement := ObjectData.Get(I);

            ObjDataElement.Get(UnitBuyerX, Value);
            Evaluate(CRMBuyer."Buyer Guid", Value);
            if ObjDataElement.Get(UnitBuyerContactX, Value) then
                Evaluate(CRMBuyer."Contact Guid", Value);
            if ObjDataElement.Get(UnitBuyerContractX, Value) then
                Evaluate(CRMBuyer."Contract Guid", Value);
            if ObjDataElement.Get(UnitBuyerOwnershipPrcX, Value) then
                Evaluate(CRMBuyer."Ownership Percentage", Value, 9)
            Else
                CRMBuyer."Ownership Percentage" := 100;
            CRMBuyer."Buyer Is Active" := true;
            if ObjDataElement.Get(UnitBuyerIsActiveX, Value) then begin
                if Value = 'false' then
                    CRMBuyer."Buyer Is Active" := false;
            end;
            if CRMBuyer."Buyer Is Active" then begin
                CRMBuyer."Expected Registration Period" := 0;
                if ObjDataElement.Get(ExpectedRegDateX, Value) then
                    Evaluate(CRMBuyer."Expected Registration Period", Value, 9);
                CRMBuyer."Agreement Start" := 0D;
                if ObjDataElement.Get(ActualDateX, Value) then begin
                    if Evaluate(TempDT, Value, 9) then
                        CRMBuyer."Agreement Start" := DT2Date(TempDT) - CRMBuyer."Expected Registration Period";
                end;
                CRMBuyer."Agreement End" := 0D;
                if ObjDataElement.Get(ExpectedDateX, Value) then begin
                    if Evaluate(TempDT, Value, 9) then
                        CRMBuyer."Agreement End" := DT2Date(TempDT);
                end;
            end;
            CRMBuyer."Version Id" := FetchedObject."Version Id";
            CRMBuyer.Insert(true);
            Commit();

            case ImportAction of
                ImportAction::Create:
                    LogEvent(FetchedObject, LogStatusEnum::Done, UnitCreatedMsg);
                ImportAction::Update:
                    LogEvent(FetchedObject, LogStatusEnum::Done, UnitUpdatedMsg);
                else
                    LogEvent(FetchedObject, LogStatusEnum::Error, 'Invalid import action');
            end
        end;
    end;

    local procedure JoinX(RootXPath: Text; ChildXPath: Text) Result: Text
    begin
        // if RootXPath <> '' then begin
        //     if not RootXPath.EndsWith('/') then
        //         RootXPath := RootXPath + '/'
        // end;
        if not RootXPath.EndsWith('/') then
            RootXPath := RootXPath + '/';
        Result := RootXPath + ChildXPath;
    end;

    local procedure LogEvent(var FetchedObject: Record "CRM Prefetched Object";
        LogToCompany: Text[60];
        LogStatusEnum: Enum "CRM Log Status";
                           LogImportActionEnum: Enum "CRM Import Action";
                           MsgText1: Text;
                           MsgText2: Text)
    var
        Log: Record "CRM Log";
    begin
        if (LogToCompany <> '') and (LogToCompany <> CompanyName()) then
            Log.ChangeCompany(LogToCompany);
        if not Log.FindLast() then
            Log."Entry No." := 1L
        else
            Log."Entry No." += 1;
        Log."Object Id" := FetchedObject.Id;
        Log."Object Type" := FetchedObject.Type;
        Log."Object Xml" := FetchedObject.Xml;
        Log."Object Version Id" := FetchedObject."Version Id";
        Log."WRQ Id" := FetchedObject."WRQ Id";
        Log."WRQ Source Company Name" := FetchedObject."WRQ Source Company Name";
        Log.Datetime := CurrentDateTime;
        Log.Status := LogStatusEnum;
        Log.Action := LogImportActionEnum;
        MsgText1 := MsgText1.Trim();
        if MsgText1 <> '' then
            Log."Details Text 1" := CopyStr(MsgText1, 1, MaxStrLen(Log."Details Text 1"))
        else begin
            if LogStatusEnum = LogStatusEnum::Error then
                Log."Details Text 1" := CopyStr(GetLastErrorText(), 1, MaxStrLen(Log."Details Text 1"));
        end;
        MsgText2 := MsgText2.Trim();
        if MsgText2 <> '' then
            Log."Details Text 2" := CopyStr(MsgText2, 1, MaxStrLen(Log."Details Text 2"))
        else begin
            if LogStatusEnum = LogStatusEnum::Error then
                Log."Details Text 2" := CopyStr(GetLastErrorCallStack(), 1, MaxStrLen(Log."Details Text 2"));
        end;
        Log.Insert();
    end;


    local procedure LogEvent(var FetchedObject: Record "CRM Prefetched Object"; LogStatusEnum: Enum "CRM Log Status"; MsgText: Text)
    var
        Log: Record "CRM Log";
    begin
        if not Log.FindLast() then
            Log."Entry No." := 1L
        else
            Log."Entry No." += 1;
        Log."Object Id" := FetchedObject.Id;
        Log."Object Type" := FetchedObject.Type;
        Log."Object Xml" := FetchedObject.Xml;
        Log."Object Version Id" := FetchedObject."Version Id";
        Log."WRQ Id" := FetchedObject."WRQ Id";
        Log.Datetime := CurrentDateTime;
        Log.Status := LogStatusEnum;
        Log."Details Text 1" := CopyStr(MsgText, 1, MaxStrLen(Log."Details Text 1"));
        Log."Details Text 2" := CopyStr(MsgText, MaxStrLen(Log."Details Text 1") + 1, MaxStrLen(Log."Details Text 2"));
        Log.Insert();
        Commit();
    end;

    local procedure LogEvent(InputObjectMetadata: Dictionary of [Text, Text]; MsgText: Text)
    var
        T: Record "CRM Prefetched Object" temporary;
        StatusEnum: Enum "CRM Log Status";
        ActionEnum: Enum "CRM Import Action";
        TempValue: Text;
        OK: Boolean;
        OutStrm: OutStream;
    begin
        T.Init();
        if InputObjectMetadata.Count <> 0 then begin
            if InputObjectMetadata.Get(T.FieldName(Id), TempValue) then
                OK := Evaluate(T.id, TempValue);
            if InputObjectMetadata.Get(T.FieldName(Type), TempValue) then
                OK := Evaluate(T.Type, TempValue);
            if InputObjectMetadata.Get(T.FieldName(Xml), TempValue) then begin
                T.Xml.CreateOutStream(OutStrm);
                OutStrm.Write(TempValue);
            end;
            if InputObjectMetadata.Get(T.FieldName("Version Id"), TempValue) then
                T."Version Id" := TempValue;
            if InputObjectMetadata.Get(T.FieldName("WRQ Id"), TempValue) then
                OK := Evaluate(T."WRQ Id", TempValue);
            if InputObjectMetadata.Get(T.FieldName("WRQ Source Company Name"), TempValue) then
                T."WRQ Source Company Name" := TempValue;
        end;
        StatusEnum := StatusEnum::Error;
        ActionEnum := ActionEnum::" ";
        LogEvent(T, CompanyName(), StatusEnum, ActionEnum, MsgText, '');
    end;

    local procedure ObjectExists(FetchedObject: record "CRM Prefetched Object") Result: Boolean
    var
        Cust: Record Customer;
        Agr: Record "Customer Agreement";
        CRMB: Record "CRM Buyers";
    begin
        case FetchedObject.Type of
            FetchedObject.Type::Unit:
                begin
                    CRMB.Reset();
                    CRMB.SetRange("Unit Guid", FetchedObject.Id);
                    CRMB.SetRange("Version Id", FetchedObject."Version Id");
                    Result := not CRMB.IsEmpty();
                end;

            FetchedObject.Type::Contact:
                begin
                    Cust.Reset();
                    Cust.Setrange("CRM GUID", FetchedObject.Id);
                    Cust.SetRange("Version Id", FetchedObject."Version Id");
                    Result := Not Cust.IsEmpty();
                end;

            FetchedObject.Type::Contract:
                begin
                    Agr.Reset();
                    Agr.SetRange("CRM GUID", FetchedObject.Id);
                    Agr.SetRange("Version Id", FetchedObject."Version Id");
                    result := not Agr.IsEmpty();
                end;
        end
    end;

    [TryFunction]
    local procedure ParseContactXml(var FetchedObject: Record "CRM Prefetched Object"; var ObjectData: List of [Dictionary of [Text, Text]])
    var
        XmlElem: XmlElement;
        XmlNode: XmlNode;
        XmlNodeList: XmlNodeList;
        OK: Boolean;
        BaseXPath: Text;
        ElemText, ElemText2, TempValue : Text;
        ObjDataElement: Dictionary of [Text, Text];
        RetObjectData: List of [Dictionary of [Text, Text]];
    begin
        ObjectData := RetObjectData;
        CreateObjDataElement(ObjectData, ObjDataElement);
        FetchedObject.CalcFields(Xml);
        GetRootXmlElement(FetchedObject, XmlElem);
        BaseXPath := JoinX(ContactX, PersonDataX);
        GetObjectField(XmlElem, ContactIdX, ObjDataElement, ContactIdX);
        GetObjectField(XmlElem, JoinX(BaseXPath, LastNameX), ObjDataElement, LastNameX);
        GetObjectField(XmlElem, JoinX(BaseXPath, FirstNameX), ObjDataElement, FirstNameX);
        GetObjectField(XmlElem, JoinX(BaseXPath, MiddleNameX), ObjDataElement, MiddleNameX);
        BaseXPath := JoinX(ContactX, PhysicalAddressX);
        if XmlNodeExists(XmlElem, BaseXPath) then begin
            ElemText2 := '';
            Ok := GetObjectField(XmlElem, JoinX(BaseXPath, PostalCityX), ObjDataElement, PostalCityX);
            Ok := GetObjectField(XmlElem, JoinX(BaseXPath, CountryCodeX), ObjDataElement, CountryCodeX);
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
                ObjDataElement.Add(AddressLineX, ElemText2);
            Ok := GetObjectField(XmlElem, JoinX(BaseXPath, PostalCodeX), ObjDataElement, PostalCodeX);
        end;
        BaseXPath := JoinX(ContactX, ElectronicAddressesX);
        if not XmlElem.SelectNodes(JoinX(BaseXPath, ElectronicAddressX), XmlNodeList) then
            exit;

        foreach XmlNode in XmlNodeList do begin
            XmlElem := XmlNode.AsXmlElement();
            if GetValue(XmlElem, ProtocolX, ElemText) and (ElemText <> '') then begin
                if GetValue(XmlElem, AddressLineX + '1', ElemText2) then begin
                    Case ElemText of
                        ContactPhoneX:
                            begin
                                if ElemText2 <> '' then begin
                                    if not ObjDataElement.Get(ContactPhoneX, TempValue) then
                                        ObjDataElement.Add(ContactPhoneX, ElemText2)
                                    else
                                        ObjDataElement.Set(ContactPhoneX, ElemText2);
                                end;
                            end;
                        ContactEmailX:
                            begin
                                if ElemText2 <> '' then begin
                                    if not ObjDataElement.Get(ContactEmailX, TempValue) then
                                        ObjDataElement.Add(ContactEmailX, ElemText2)
                                    else
                                        ObjDataElement.Set(ContactEmailX, ElemText2);
                                end;
                            end;
                    End
                end;
            end;
        end;

    end;


    [TryFunction]
    local procedure ParseContractXml(var FetchedObject: Record "CRM Prefetched Object"; var ObjectData: List of [Dictionary of [Text, Text]])
    var
        XmlElem: XmlElement;
        XmlBuyer: XmlNode;
        XmlBuyerList: XmlNodeList;
        OK: Boolean;
        ObjDataElement: Dictionary of [Text, Text];
        RetObjectData: List of [Dictionary of [Text, Text]];
        AgrType, AgrStatus : Text;
    begin
        ObjectData := RetObjectData;
        CreateObjDataElement(ObjectData, ObjDataElement);
        FetchedObject.CalcFields(Xml);
        GetRootXmlElement(FetchedObject, XmlElem);
        GetObjectField(XmlElem, ContractIdX, ObjDataElement, ContractIdX);
        GetObjectField(XmlElem, ContractUnitIdX, ObjDataElement, ContractUnitIdX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractNoX), ObjDataElement, ContractNoX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractTypeX), ObjDataElement, ContractTypeX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractStatusX), ObjDataElement, ContractStatusX);
        if ObjDataElement.Get(ContractTypeX, AgrType) and ObjDataElement.Get(ContractStatusX, AgrType) then begin
            AgrType := AgrType.ToUpper();
            AgrStatus := AgrStatus.ToUpper();
            if (AgrType in ['SALESCONTRACT', 'PRELIMINARYSALESCONTRACT'])
                and (not (AgrStatus.StartsWith('SIGNED') or AgrStatus.StartsWith('REGISTERED')))
            then
                Error(ContractNotSignedErr, AgrType, AgrStatus);
            if (AgrType in ['TRANSFEROFRIGHTS', 'TRANSFEROFRIGHTSINTERNALLY', 'INVESTMENTCONTRACT'])
                    and (not AgrStatus.StartsWith('REGISTERED'))
            then
                Error(ContractNotRegisteredErr, AgrType, AgrStatus);
        end;
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractCancelStatusX), ObjDataElement, ContractCancelStatusX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractIsActiveX), ObjDataElement, ContractIsActiveX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ExtAgreementNoX), ObjDataElement, ExtAgreementNoX);
        GetObjectField(XmlElem, JoinX(ContractX, ApartmentAmountX), ObjDataElement, ApartmentAmountX);
        OK := GetObjectField(XmlElem, JoinX(ContractX, FinishingInclX), ObjDataElement, FinishingInclX);
        if XmlElem.SelectNodes(JoinX(ContractX, ContractBuyerNodesX), XmlBuyerList) then begin
            foreach XmlBuyer in XmlBuyerList do begin
                XmlElem := XmlBuyer.AsXmlElement();
                CreateObjDataElement(ObjectData, ObjDataElement);
                GetObjectField(XmlElem, ContractBuyerX, ObjDataElement, ContractBuyerX);
            end;
        end;
    end;

    local procedure ParseObjects(var FetchedObject: Record "CRM Prefetched Object"; var AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]])
    var
        ParsingResult: Dictionary of [Text, Text];
        ObjectData: List of [Dictionary of [Text, Text]];
        HasError: Boolean;
        LogStatusEnum: Enum "CRM Log Status";
    begin
        FetchedObject.Reset();
        FetchedObject.FindSet();
        repeat
            Clear(ParsingResult);
            case FetchedObject.Type of
                FetchedObject.Type::Unit:
                    hasError := not ParseUnitXml(FetchedObject, ObjectData);
                FetchedObject.Type::Contact:
                    hasError := not ParseContactXml(FetchedObject, ObjectData);
                FetchedObject.Type::Contract:
                    hasError := not ParseContractXml(FetchedObject, ObjectData);
            end;
            if not HasError then begin
                if ObjectData.Count <> 0 then
                    AllObjectData.Add(FetchedObject.Id, ObjectData);
            end else begin
                LogEvent(FetchedObject, LogStatusEnum::Error, GetLastErrorText());
                FetchedObject.Delete();
            end;

        until FetchedObject.Next() = 0;
    end;

    [TryFunction]
    local procedure ParseUnitXml(var FetchedObject: Record "CRM Prefetched Object"; var ObjectData: List of [Dictionary of [Text, Text]])
    var
        XmlElem: XmlElement;
        XmlBuyer: XmlNode;
        XmlBuyerList: XmlNodeList;
        ElemText, ElemText2 : Text;
        BuyerNo: Integer;
        ExpectedRegDate, ActualDate, ExpectedDate : Text;
        OK: Boolean;
        ObjDataElement: Dictionary of [Text, Text];
        RetObjectData: List of [Dictionary of [Text, Text]];
    begin
        ObjectData := RetObjectData;
        CreateObjDataElement(ObjectData, ObjDataElement);
        FetchedObject.CalcFields(Xml);
        GetRootXmlElement(FetchedObject, XmlElem);
        GetValue(XmlElem, JoinX(UnitBaseDataX, ObjectParentIdX), ElemText);
        GetObjectField(XmlElem, UnitIdX, ObjDataElement, UnitIdX);
        GetObjectField(XmlElem, JoinX(UnitBaseDataX, ReservingContactX), ObjDataElement, ReservingContactX);
        GetObjectField(XmlElem, JoinX(UnitBaseDataX, InvestmentObjectX), ObjDataElement, InvestmentObjectX);
        OK := GetObjectField(XmlElem, JoinX(UnitBaseDataX, BlockNumberX), ObjDataElement, BlockNumberX);
        OK := GetObjectField(XmlElem, JoinX(UnitBaseDataX, ApartmentNumberX), ObjDataElement, ApartmentNumberX);
        OK := GetObjectField(XmlElem, JoinX(UnitX, ApartmentOriginTypeX), ObjDataElement, ApartmentOriginTypeX);
        OK := GetObjectField(XmlElem, JoinX(UnitX, ApartmentUnitAreaM2X), ObjDataElement, ApartmentUnitAreaM2X);
        OK := GetObjectField(XmlElem, JoinX(UnitX, ExpectedRegDateX), ObjDataElement, ExpectedRegDateX);
        OK := GetObjectField(XmlElem, JoinX(UnitX, ActualDateX), ObjDataElement, ActualDateX);
        OK := GetObjectField(XmlElem, JoinX(UnitX, ExpectedDateX), ObjDataElement, ExpectedDateX);
        if not XmlElem.SelectNodes(JoinX(UnitX, UnitBuyerNodesX), XmlBuyerList) then
            exit;
        foreach XmlBuyer in XmlBuyerList do begin
            XmlElem := XmlBuyer.AsXmlElement();
            CreateObjDataElement(ObjectData, ObjDataElement);
            GetObjectField(XmlElem, UnitBuyerX, ObjDataElement, UnitBuyerX);
            GetObjectField(XmlElem, UnitBuyerContactX, ObjDataElement, UnitBuyerContactX);
            GetObjectField(XmlElem, UnitBuyerContractX, ObjDataElement, UnitBuyerContractX);
            OK := GetObjectField(XmlElem, UnitBuyerOwnershipPrcX, ObjDataElement, UnitBuyerOwnershipPrcX);
            OK := GetObjectField(XmlElem, UnitBuyerIsActiveX, ObjDataElement, UnitBuyerIsActiveX);
        end;
    end;

    local procedure PickupPrefetchedObjects(var TempFetchedObject: Record "CRM Prefetched Object")
    var
        PrefetchedObj: Record "CRM Prefetched Object";
    begin
        PrefetchedObj.Reset();
        if PrefetchedObj.FindSet() then
            repeat
                TempFetchedObject := PrefetchedObj;
                if TempFetchedObject.Insert() then;
            until PrefetchedObj.Next() = 0;
    end;

    local procedure SetObjectDataElementPointer(ObjectDataElements: List of [Dictionary of [Text, Text]]; ElementNo: Integer)
    begin
        ObjectDataElementPointer := ObjectDataElements.Get(ElementNo);
    end;

    local procedure SetShareholderAttributes(var CustAgreement: Record "Customer Agreement"; ShareholderNo: Integer; CustomerNo: Code[20]; ContactNo: Code[20]; OwnershipPrc: Decimal)
    begin
        case ShareholderNo - 1 of
            CustAgreement."Share in property 3"::pNo:
                begin
                    CustAgreement."Customer No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::pNo;
                    CustAgreement."Amount part 1" := OwnershipPrc;
                    //CustAgreement.Contact := GetContactFromCustomer(CustomerNo);
                    CustAgreement.Contact := ContactNo;
                    CustAgreement."Contact 1" := CustAgreement.Contact;
                end;
            CustAgreement."Share in property 3"::Owner2:
                begin
                    CustAgreement."Customer 2 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner2;
                    CustAgreement."Amount part 2" := OwnershipPrc;
                    //CustAgreement."Contact 2" := GetContactFromCustomer(CustomerNo);
                    CustAgreement."Contact 2" := ContactNo;

                end;
            CustAgreement."Share in property 3"::Owner3:
                begin
                    CustAgreement."Customer 3 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner3;
                    CustAgreement."Amount part 3" := OwnershipPrc;
                    //CustAgreement."Contact 3" := GetContactFromCustomer(CustomerNo);
                    CustAgreement."Contact 3" := ContactNo;
                end;
            CustAgreement."Share in property 3"::Owner4:
                begin
                    CustAgreement."Customer 4 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner4;
                    CustAgreement."Amount part 4" := OwnershipPrc;
                    //CustAgreement."Contact 4" := GetContactFromCustomer(CustomerNo);
                    CustAgreement."Contact 4" := ContactNo;
                end;
            CustAgreement."Share in property 3"::Owner5:
                begin
                    CustAgreement."Customer 5 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner5;
                    CustAgreement."Amount part 5" := OwnershipPrc;
                    //CustAgreement."Contact 5" := GetContactFromCustomer(CustomerNo);
                    CustAgreement."Contact 5" := ContactNo;
                end;
        end
    end;

    local procedure SetTargetCompany(var FetchedObject: Record "CRM Prefetched Object"; var AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]])
    var
        CrmInteractCompanies: List of [Text];
        BuyerToContractMap, UnitBuyerToContactMap, ObjectDataElement : Dictionary of [Text, Text];
        ObjectData: List of [Dictionary of [Text, Text]];
        C, I : Integer;
        TextKey, ContactId, BuyerId, ContractId, UnitId : Text;
        DbgList: List of [Text];
        DbgVal, DbgErr : Text;
    begin
        if AllObjectData.Count() = 0 then
            exit;
        FetchedObject.Reset();
        FetchedObject.SetFilter(Type, '%1|%2', FetchedObject.Type::Unit, FetchedObject.Type::Contract);
        if FetchedObject.FindSet() then begin
            repeat
                AllObjectData.Get(FetchedObject.Id, ObjectData);

                //walkthrough of object head(I=1) and buyres (I>1)
                C := ObjectData.Count;
                if C > 1 then begin
                    for I := 1 to C do begin
                        ObjectDataElement := ObjectData.Get(I);
                        case FetchedObject.Type of
                            FetchedObject.Type::Unit:
                                begin
                                    if I = 1 then begin
                                        ObjectDataElement.Get(UnitIdX, UnitId)
                                    end else begin
                                        if ObjectDataElement.Get(UnitBuyerX, BuyerId) and ObjectDataElement.Get(UnitBuyerContactX, ContactId) then begin
                                            TextKey := UnitId + '@' + BuyerId;
                                            UnitBuyerToContactMap.Add(TextKey, ContactId);
                                        end;
                                    end;
                                end;
                            FetchedObject.Type::Contract:
                                begin
                                    if I = 1 then begin
                                        ObjectDataElement.Get(ContractIdX, ContractId);
                                    end else begin
                                        ObjectDataElement.Get(ContractBuyerX, BuyerId);
                                        BuyerToContractMap.Add(BuyerId, ContractId);
                                    end;
                                end;
                        end
                    end;
                end;
            until FetchedObject.Next() = 0;
        end;

        GetCrmInteractCompanyList(CrmInteractCompanies);
        FetchedObject.Reset();
        FetchedObject.SetFilter("Company name", '%1', '');
        if FetchedObject.FindSet() then begin
            repeat
                FetchedObject."Company name" :=
                    SuggestTargetCompany(FetchedObject, AllObjectData, BuyerToContractMap, UnitBuyerToContactMap, CrmInteractCompanies);
                if FetchedObject."Company name" <> '' then
                    FetchedObject.Modify();
            until FetchedObject.Next() = 0;
        end;
    end;

    local procedure SuggestTargetCompany(var FetchedObject: Record "CRM Prefetched Object";
        var AllObjectData: Dictionary of [Guid, List of [Dictionary of [Text, Text]]];
        BuyerToContractMap: Dictionary of [Text, Text];
        UnitBuyerToContactMap: Dictionary of [Text, Text];
        CrmInteractCompanyList: List of [Text]) Result: Text[60]
    var
        LogStatusEnum: Enum "CRM Log Status";
        CrmCompany: Record "CRM Company";
        TempFetchedObject: Record "CRM Prefetched Object" temporary;
        CrmBuyer: Record "CRM Buyers";
        TempGuid, TempUnitGuid, ProjectId : Guid;
        ObjectData: List of [Dictionary of [Text, Text]];
        ObjectDataElement: Dictionary of [Text, Text];
        NewCompanyName, TempContactIdText, TempContractBuyerIdText, TempUnitIdText : Text;
        TempKey, TempValue : Text;
        TempKeyList: List of [Text];
    begin
        Result := '';
        TempFetchedObject := FetchedObject;

        case TempFetchedObject.Type of
            TempFetchedObject.Type::Unit:
                begin
                    if CrmCompany.Get(TempFetchedObject.ParentId) then
                        Result := CrmCompany."Company Name"
                    else
                        LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ProjectNotFoundErr, TempFetchedObject.ParentId))
                end;
            TempFetchedObject.Type::Contact:
                begin
                    if UnitBuyerToContactMap.Count <> 0 then begin
                        TempKeyList := UnitBuyerToContactMap.Keys();
                        foreach TempKey in TempKeyList do begin
                            UnitBuyerToContactMap.Get(TempKey, TempContactIdText);
                            Evaluate(TempGuid, TempContactIdText);
                            if TempGuid = TempFetchedObject.Id then begin
                                TempContractBuyerIdText := TempKey.Split('@').Get(2);
                                if BuyerToContractMap.Get(TempContractBuyerIdText, TempValue) then begin
                                    TempUnitIdText := TempKey.Split('@').Get(1);
                                    Evaluate(TempUnitGuid, TempUnitIdText);
                                    if FetchedObject.Get(TempUnitGuid) then begin
                                        if CrmCompany.Get(FetchedObject.ParentId) then begin
                                            Result := CrmCompany."Company Name";
                                            break;
                                        end else begin
                                            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ProjectNotFoundErr, FetchedObject.ParentId))
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    if Result = '' then begin
                        foreach NewCompanyName in CrmInteractCompanyList do begin
                            CrmBuyer.Reset();
                            CrmBuyer.ChangeCompany(NewCompanyName);
                            CrmBuyer.SetRange("Contact Guid", TempFetchedObject.id);
                            if not CrmBuyer.IsEmpty then
                                Result := NewCompanyName
                            else begin
                                CrmBuyer.SetRange("Contact Guid");
                                CrmBuyer.SetRange("Reserving Contact Guid", TempFetchedObject.id);
                                if not CrmBuyer.IsEmpty then
                                    Result := NewCompanyName;
                            end;
                            if Result <> '' then
                                break;
                        end;
                    end;
                end;
            TempFetchedObject.Type::Contract:
                begin
                    if AllObjectData.Get(TempFetchedObject.ParentId, ObjectData) then begin
                        FetchedObject.Get(TempFetchedObject.ParentId);
                        if CrmCompany.Get(FetchedObject.ParentId) then
                            Result := CrmCompany."Company Name"
                        else
                            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ProjectNotFoundErr, FetchedObject.ParentId));
                    end;
                    if Result = '' then begin
                        foreach NewCompanyName in CrmInteractCompanyList do begin
                            CrmBuyer.Reset();
                            CrmBuyer.ChangeCompany(NewCompanyName);
                            CrmBuyer.SetRange("Contract Guid", TempFetchedObject.id);
                            if not CrmBuyer.IsEmpty then
                                Result := NewCompanyName
                            else begin
                                CrmBuyer.SetRange("Contract Guid");
                                CrmBuyer.SetRange("Reserving Contract Guid", TempFetchedObject.id);
                                if not CrmBuyer.IsEmpty then
                                    Result := NewCompanyName;
                            end;
                            if Result <> '' then
                                break;
                        end;
                    end;

                end;
        end;

        FetchedObject := TempFetchedObject;
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

    [TryFunction]
    local procedure XmlNodeExists(XmlElem: XmlElement; XPath: Text)
    var
        TempXmlNode: XmlNode;
    begin
        XmlElem.SelectSingleNode(XPath, TempXmlNode);
    end;
}
