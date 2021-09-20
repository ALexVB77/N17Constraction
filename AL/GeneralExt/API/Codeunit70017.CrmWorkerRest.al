codeunit 70017 "Crm Worker Rest"
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
        UnknownInvestObjectTypeValueErr: Label 'Unknown Investment Object Type %1';

        FieldTypeMismatchErr: Label 'Field type mismatch. %1 must be %2';


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

        MsgBuffG: Record "Crm Message Buffer";
        SubMsgBuffG: Record "Crm Sub Message Buffer";
        MsgBuffRecRefG: RecordRef;
        SubMsgBuffRecRefG: RecordRef;


    procedure GetApartmentType(SoapEnvBody: Text) Response: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        RootXmlElement: XmlElement;
        XmlValues: array[3] of Text;
        ObjectXmlText: Text;
        TempDT: DateTime;
        OK: Boolean;
        ExpectedRegPeriod: Integer;
    begin
        if not GetRootXmlElement(SoapEnvBody, RootXmlElement) then
            Error('No soapp envelope body!');
        ObjectXmlText := Base64Convert.FromBase64(SoapEnvBody);
        GetRootXmlElement(ObjectXmlText, RootXmlElement);
        GetValue(RootXmlElement, UnitIdX, XmlValues[1]);
        OK := GetValue(RootXmlElement, JoinX(UnitBaseDataX, ApartmentNumberX), XmlValues[2]);
        OK := GetValue(RootXmlElement, JoinX(UnitX, ApartmentOriginTypeX), XmlValues[3]);
        if (XmlValues[2] <> '') or (XmlValues[3] <> '') then begin
            Response := StrSubstNo('%1;%2;%3', XmlValues[1], XmlValues[2], XmlValues[3]);
        end;
    end;

    procedure ImportObjects(var FetchedObject: Record "CRM Prefetched Object")
    var
        TargetCompany: Text[60];
        ImportActionEnum: Enum "CRM Import Action";
        LogStatusEnum: Enum "CRM Log Status";
        Updated: Boolean;
    begin

        ParseObjects(FetchedObject);

        if ParsedObjectsG.Count() = 0 then
            Error('DBG: ParsedObjectsG is empty');

        //create/update units
        FetchedObject.SetRange(Type, FetchedObject.Type::Unit);
        if FetchedObject.FindSet() then begin
            repeat
                ImportActionEnum := GetObjectImportAction(FetchedObject);
                If ImportActionEnum = ImportActionEnum::NoAction then
                    LogEvent(FetchedObject, LogStatusEnum::Done, AllUpToDateMsg)
                else
                    ImportUnit(FetchedObject, ImportActionEnum);
            until FetchedObject.Next() = 0;
            FetchedObject.DeleteAll(true);
            Commit();
        end;

        // update contacts
        GetCrmInteractCompanyList();
        FetchedObject.SetRange(Type, FetchedObject.Type::Contact);
        if FetchedObject.FindSet() then begin
            repeat
                Updated := false;
                foreach TargetCompany in CrmInteractCompanyListG do begin
                    ImportActionEnum := GetObjectImportAction(FetchedObject, TargetCompany);
                    case ImportActionEnum of
                        ImportActionEnum::Update:
                            begin
                                Updated := true;
                                ImportContact(FetchedObject, TargetCompany, ImportActionEnum);
                            end;
                        ImportActionEnum::NoAction:
                            begin
                                Updated := true;
                                LogEvent(FetchedObject, LogStatusEnum::Done, AllUpToDateMsg);
                            end;
                    end
                end;
                if Updated then
                    DeleteObjectFromImport(FetchedObject);
            until FetchedObject.Next() = 0;
            Commit();
        end;

        FetchedObject.SetRange(Type, FetchedObject.Type::Contract);
        if FetchedObject.FindSet() then begin
            repeat
                Updated := false;
                ImportActionEnum := GetObjectImportAction(FetchedObject);
                case ImportActionEnum of
                    ImportActionEnum::NoAction:
                        begin
                            Updated := true;
                            LogEvent(FetchedObject, LogStatusEnum::Done, AllUpToDateMsg);
                        end
                    else begin
                            Updated := true;
                            ImportContract(FetchedObject, ImportActionEnum);
                        end;
                end;
                if Updated then
                    FetchedObject.Delete();
            until FetchedObject.Next() = 0;
            Commit();
        end;

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

    local procedure Code(var WebRequestQueue: Record "Web Request Queue")
    var
        FetchedObjectBuff: Record "CRM Prefetched Object" temporary;
        FetchedObject: Record "CRM Prefetched Object";
    begin
        PickupPrefetchedObjects(FetchedObjectBuff);
        if not FetchObjects(WebRequestQueue, FetchedObjectBuff) then
            exit;

        ParseObjects(FetchedObjectBuff);
        SetTargetCompany(FetchedObjectBuff);
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

    local procedure CopyCustomer(CrmContactId: Guid; CopyFromCompanyName: Text[60]; CopyFromCustomerNo: Code[20]) Result: Code[20]
    var
        CopyFromCustomer, Customer : Record Customer;
        CrmSetup: Record "CRM Integration Setup";
        UpdateContFromCust: Codeunit "CustCont-Update";
        ContBusRelation: Record "Contact Business Relation";
    begin
        if IsNullGuid(CrmContactId) then
            Error('DBG: CopyCustomer - CrmContactId is null');
        CopyFromCustomer.Reset();
        CopyFromCustomer.Setrange("CRM GUID", CrmContactId);
        if Not CopyFromCustomer.IsEmpty then
            Error('DBG: CopyCustomer - Customer with id %1 already exists in Company %2', CrmContactId, CompanyName());

        if CopyFromCompanyName = '' then
            Error('DBG: CopyCustomer - CopyFromCompanyName is empty');

        CopyFromCustomer.ChangeCompany(CopyFromCompanyName);

        //CopyFromCustomer.SetRange("CRM GUID", CrmContactId);
        //if not CopyFromCustomer.FindFirst() then
        if not CopyFromCustomer.Get(CopyFromCustomerNo) then
            Error('DBG: CopyCustomer - Customer %1 is not found in Company %2', CrmContactId, CompanyName());

        CrmSetup.Get;
        Customer := CopyFromCustomer;
        Customer."No." := '';
        Customer.Validate("Agreement Posting", Customer."Agreement Posting"::Mandatory);
        if Customer."Customer Posting Group" = '' then
            Customer.Validate("Customer Posting Group", CrmSetup."Customer Posting Group");
        if Customer."Gen. Bus. Posting Group" = '' then
            Customer.Validate("Gen. Bus. Posting Group", CrmSetup."Gen. Bus. Posting Group");
        if Customer."VAT Bus. Posting Group" = '' then
            Customer.Validate("VAT Bus. Posting Group", CrmSetup."VAT Bus. Posting Group");
        ContBusRelation.SETCURRENTKEY("Link to Table", "No.");
        ContBusRelation.SetRange("Link to Table", ContBusRelation."Link to Table"::Customer);
        ContBusRelation.SetRange("No.", Customer."No.");
        if not ContBusRelation.FindFirst() then
            UpdateContFromCust.InsertNewContact(Customer, FALSE);
        Customer.Insert(true);
        Result := Customer."No.";
    end;

    local procedure CreateObjDataElement(var ObjList: List of [Dictionary of [Text, Text]]; var NewElement: Dictionary of [Text, Text])
    var
        SomeDict: Dictionary of [Text, Text];
    begin
        NewElement := SomeDict;
        ObjList.Add(NewElement);
    end;

    local procedure CreateServiceAgreement(var FetchedObject: Record "CRM Prefetched Object"; var BaseAgr: Record "Customer Agreement"; ShareHolderNo: Integer)
    var
        AgrCustomerNo: Code[20];
        Agr: Record "Customer Agreement";
        LogStatusEnum: Enum "CRM Log Status";
    begin
        case ShareHolderNo of
            2:
                AgrCustomerNo := BaseAgr."Customer 2 No.";
            3:
                AgrCustomerNo := BaseAgr."Customer 3 No.";
            4:
                AgrCustomerNo := BaseAgr."Customer 4 No.";
            5:
                AgrCustomerNo := BaseAgr."Customer 5 No.";
        end;
        if AgrCustomerNo = '' then
            exit;
        if Agr.Get(AgrCustomerNo, BaseAgr."No.") then
            exit;
        Agr := BaseAgr;
        Agr."Customer No." := AgrCustomerNo;
        Agr."Agreement Type" := Agr."Agreement Type"::Service;
        Clear(Agr."CRM GUID");
        Clear(Agr."Version Id");
        UpdateAgreementPostingSettings(Agr);
        Agr.Insert(true);
        LogEvent(FetchedObject, LogStatusEnum::Done,
            StrSubstNo(ContractCreatedMsg,
                Agr."No.",
                Agr.FieldCaption("Agreement Type"),
                Agr."Agreement Type",
                Agr.FieldCaption(Status),
                Agr.Status))
    end;

    local procedure DeleteObjectFromImport(var FetchedObject: Record "CRM Prefetched Object")
    var
        OK: Boolean;
    begin
        OK := ParsedObjectsG.Remove(FetchedObject.Id);
        OK := FetchedObject.Delete();
    end;

    [TryFunction]
    local procedure DGet(TKey: Text; var TValue: Text)
    begin
        TValue := '';
        if not ObjectDataElementG.Get(TKey, TValue) then begin
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


    local procedure FindCustomer(ShareHolderNo: Integer;
        ContactId: Guid;
        BuyerId: Guid;
        ReserveContact: Boolean;
        var CustomerLocations: Dictionary of [Integer /*ShareholderNo*/, List of [Text] /*index 1 - contact guid; 2 - where to search; 3 - what customer no found; 4 -Buyer guid; 5 - is reserve contact */]
        ) ActualCustomerNo: Code[20]
    var
        ObjectDataElementList: List of [Dictionary of [Text, Text]];
        Cust: Record Customer;
        SearchInCompanyName: Text;
        WhereToSearch: Text;
        FoundCustNo: Code[20];
        CustomerFound: Boolean;
    begin
        ActualCustomerNo := '';
        CustomerFound := false;

        if ParsedObjectsG.Get(ContactId, ObjectDataElementList) then begin
            WhereToSearch := CustomerSearchInReceivingData;
            CustomerFound := true;
        end else begin
            Cust.Reset();
            Cust.SetRange("CRM GUID", ContactId);
            if not Cust.IsEmpty() then begin
                Cust.FindFirst();
                ActualCustomerNo := Cust."No.";
                WhereToSearch := CustomerSearchCurrentCompany;
                FoundCustNo := Cust."No.";
                CustomerFound := true;
            end else begin
                foreach SearchInCompanyName in CrmInteractCompanyListG do begin
                    if SearchInCompanyName <> CompanyName() then begin
                        Cust.Reset();
                        Cust.ChangeCompany(SearchInCompanyName);
                        Cust.SetRange("CRM GUID", ContactId);
                        if not Cust.IsEmpty() then begin
                            Cust.FindFirst();
                            WhereToSearch := SearchInCompanyName;
                            FoundCustNo := Cust."No.";
                            CustomerFound := true;
                            break;
                        end;
                    end;
                end;
            end;
        end;

        if CustomerFound then
            FindCustomerHelper(ShareHolderNo,
                ContactId,
                WhereToSearch,
                FoundCustNo,
                BuyerId,
                ReserveContact,
                CustomerLocations);
    end;

    local procedure FindCustomerHelper(ShareHolderNo: Integer;
        ContactId: Guid;
        WhereToSearch: Text;
        FoundCustomerNo: Code[20];
        BuyerId: Guid;
        ReserveContact: Boolean;
        var CustomerLocations: Dictionary of [Integer, List of [Text]])
    var
        SearchParamList: List of [Text];
    begin
        SearchParamList.Add(Format(ContactId));
        SearchParamList.Add(WhereToSearch);
        SearchParamList.Add(FoundCustomerNo);
        SearchParamList.Add(Format(BuyerId));
        if ReserveContact then
            SearchParamList.Add(CustomerSearchReserveContact)
        else
            SearchParamList.Add('');
        CustomerLocations.Add(ShareHolderNo, SearchParamList);
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

    local procedure GetBuyerCount() Result: Integer
    begin
        Result := ObjectDataElementListG.Count - 1;
        if Result < 0 then
            Error('DBG: GetBuyerCount - Count is a negative number');
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

    local procedure GetCrmInteractCompanyList()
    var
        CrmCompany: Record "CRM Company";
    begin
        Clear(CrmInteractCompanyListG);
        CrmCompany.Reset();
        CrmCompany.FindSet();
        repeat
            Clear(CrmInteractCompanyListG);
            if CrmCompany."Company Name" <> '' then begin
                if not CrmInteractCompanyListG.Contains(CrmCompany."Company Name") then
                    CrmInteractCompanyListG.Add(CrmCompany."Company Name");
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
    local procedure GetTargetCrmCompany(var FetchedObject: Record "CRM Prefetched Object"; var TargetCompanyName: Text)
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
                    foreach CrmCompanyname in CrmInteractCompanyListG do begin
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
                    foreach CrmCompanyname in CrmInteractCompanyListG do begin
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
        TargetCompanyName: Text[60];
        ImportActionEnum: Enum "CRM Import Action") Result: Code[20]
    var
        CustTemp: Record Customer temporary;
        LogStatusEnum: Enum "CRM Log Status";
    begin
        if ValidateContactData(FetchedObject, CustTemp) then
            Result := WriteContactToDB(FetchedObject, CustTemp, TargetCompanyName, ImportActionEnum)
        else
            LogEvent(FetchedObject, LogStatusEnum::Error, GetLastErrorText())

    end;

    local procedure ImportContract(var FetchedObject: Record "CRM Prefetched Object"; ImportActionEnum: Enum "CRM Import Action") Result: Code[20]
    var
        AgrTemp: Record "Customer Agreement" temporary;
        ShareHolderNo: Integer;
        CustomerLocations: Dictionary of [Integer /*ShareholderNo*/, List of [Text]];
        SearchParamList: List of [Text];
        CrmContactId: Guid;
        FetchedObject2: Record "CRM Prefetched Object";
        LogStatusEnum: Enum "CRM Log Status";
        HasError: Boolean;
        CustNo, AgrNo : Code[20];
    begin
        if not ValidateContractData(FetchedObject, AgrTemp, CustomerLocations) then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, GetLastErrorText());
            exit;
        end;

        //create linked contacts
        foreach ShareHolderNo in CustomerLocations.Keys() do begin
            CustomerLocations.Get(ShareHolderNo, SearchParamList);
            if (not Evaluate(CrmContactId, SearchParamList.Get(1))) or IsNullGuid(CrmContactId) then
                Error('DBG: ImportContract - Bad Crm Contact guid');

            case SearchParamList.Get(2) of
                CustomerSearchInReceivingData:
                    begin
                        FetchedObject2.Get(CrmContactId);
                        CustNo := ImportContact(FetchedObject2, '', ImportActionEnum::Create);
                        FetchedObject2.Delete(true);
                    end;
                CustomerSearchCurrentCompany:
                    CustNo := SearchParamList.Get(3);
                else
                    CustNo := CopyCustomer(CrmContactId, SearchParamList.Get(2), SearchParamList.Get(3));
            end;
            if CustNo = '' then
                HasError := true
            else begin
                SetShareholderAttributes(AgrTemp, ShareHolderNo, CustNo, GetContactFromCustomer(CustNo));
            end;
        end;
        if HasError then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, ContractNotCreated2Err);
            exit;
        end;

        if not ValidateContractData2(FetchedObject, AgrTemp) then begin
            LogEvent(FetchedObject, LogStatusEnum::Error, GetLastErrorText());
            exit;
        end;

        Result := WriteContractToDb(FetchedObject, AgrTemp, CustomerLocations, ImportActionEnum);
    end;

    local procedure ImportUnit(var FetchedObject: Record "CRM Prefetched Object"; ImportActionEnum: Enum "CRM Import Action") Result: Boolean
    var
        CrmBTemp: Record "CRM Buyers" temporary;
        ApartmentTemp: Record "Investment Object" temporary;
        LogStatusEnum: Enum "CRM Log Status";
    begin
        Result := true;
        if ValidateUnitData(FetchedObject, CrmBTemp, ApartmentTemp) then
            WriteUnitToDB(FetchedObject, CrmBTemp, ApartmentTemp, ImportActionEnum)
        else begin
            LogEvent(FetchedObject, LogStatusEnum::Error, GetLastErrorText());
            Result := false
        end;

    end;

    local procedure JoinX(RootXPath: Text; ChildXPath: Text) Result: Text
    begin
        if not RootXPath.EndsWith('/') then
            RootXPath := RootXPath + '/';
        Result := RootXPath + ChildXPath;
    end;

    local procedure LogEvent(var FetchedObject: Record "CRM Prefetched Object";
        TargetCompanyName: Text[60];
        LogStatusEnum: Enum "CRM Log Status";
        LogImportActionEnum: Enum "CRM Import Action";
        MsgText1: Text;
        MsgText2: Text)
    var
        Log: Record "CRM Log" temporary;
        SessionId: Integer;
    begin
        Log.Init();
        Log."Entry No." := 0L;
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

        if TargetCompanyName = '' then
            TargetCompanyName := CompanyName();
        if not StartSession(SessionId, Codeunit::"Crm Log Management", TargetCompanyName, Log) then
            Error(StartSessionErr);
    end;

    local procedure LogEvent(var FetchedObject: Record "CRM Prefetched Object"; LogStatusEnum: Enum "CRM Log Status"; MsgText: Text)
    var
        Log: Record "CRM Log";
        ImportActionEnum: Enum "CRM Import Action";
    begin
        LogEvent(FetchedObject,
            CompanyName(),
            LogStatusEnum,
            ImportActionEnum::" ",
            CopyStr(MsgText, 1, MaxStrLen(Log."Details Text 1")),
            CopyStr(MsgText, MaxStrLen(Log."Details Text 1") + 1, MaxStrLen(Log."Details Text 2")));
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
        ElemText, ElemText2, TempValue, LastValidPhoneNo, LastValidMailAddress : Text;
        ObjDataElement: Dictionary of [Text, Text];
        RetObjectData: List of [Dictionary of [Text, Text]];
        LogStatusEnum: Enum "CRM Log Status";
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
                                    if not CheckValidPhoneNo(ElemText2) then
                                        LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(InvalidPhoneNoErr, ElemText2))
                                    else begin
                                        LastValidPhoneNo := ElemText2;
                                        if not ObjDataElement.Get(ContactPhoneX, TempValue) then
                                            ObjDataElement.Add(ContactPhoneX, LastValidPhoneNo)
                                        else
                                            ObjDataElement.Set(ContactPhoneX, LastValidPhoneNo);
                                    end;
                                end;
                            end;
                        ContactEmailX:
                            begin
                                if ElemText2 <> '' then begin
                                    if not CheckValidMailAddress(ElemText2) then
                                        LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(InvalidEmailAddressErr, ElemText2))
                                    else begin
                                        LastValidMailAddress := ElemText2;
                                        if not ObjDataElement.Get(ContactEmailX, TempValue) then
                                            ObjDataElement.Add(ContactEmailX, LastValidMailAddress)
                                        else
                                            ObjDataElement.Set(ContactEmailX, LastValidMailAddress);
                                    end;
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
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractCancelStatusX), ObjDataElement, ContractCancelStatusX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ContractIsActiveX), ObjDataElement, ContractIsActiveX);
        GetObjectField(XmlElem, JoinX(ContractBaseDataX, ExtAgreementNoX), ObjDataElement, ExtAgreementNoX);
        GetObjectField(XmlElem, JoinX(ContractX, AgreementAmountX), ObjDataElement, AgreementAmountX);
        OK := GetObjectField(XmlElem, JoinX(ContractX, FinishingInclX), ObjDataElement, FinishingInclX);
        if XmlElem.SelectNodes(JoinX(ContractX, ContractBuyerNodesX), XmlBuyerList) then begin
            foreach XmlBuyer in XmlBuyerList do begin
                XmlElem := XmlBuyer.AsXmlElement();
                CreateObjDataElement(ObjectData, ObjDataElement);
                GetObjectField(XmlElem, ContractBuyerX, ObjDataElement, ContractBuyerX);
            end;
        end;
    end;

    local procedure ParseObjects(var FetchedObject: Record "CRM Prefetched Object")
    var
        ParsingResult: Dictionary of [Text, Text];
        ObjectData: List of [Dictionary of [Text, Text]];
        HasError: Boolean;
        LogStatusEnum: Enum "CRM Log Status";
    begin
        Clear(ParsedObjectsG);
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
                    ParsedObjectsG.Add(FetchedObject.Id, ObjectData);
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

    [TryFunction]
    local procedure SetObjectDataElementPointer(ElementNo: Integer)
    begin
        ObjectDataElementG := ObjectDataElementListG.Get(ElementNo);
    end;

    [TryFunction]
    local procedure SetObjectDataPointer(CrmObjectId: Guid)
    begin
        ParsedObjectsG.Get(CrmObjectId, ObjectDataElementListG);
    end;


    local procedure SetShareholderAttributes(var CustAgreement: Record "Customer Agreement"; ShareholderNo: Integer; CustomerNo: Code[20]; ContactNo: Code[20]; OwnershipPrc: Decimal)
    begin
        case ShareholderNo - 1 of
            CustAgreement."Share in property 3"::pNo:
                begin
                    CustAgreement."Customer No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::pNo;
                    CustAgreement."Amount part 1" := OwnershipPrc;
                    CustAgreement.Contact := ContactNo;
                    CustAgreement."Contact 1" := CustAgreement.Contact;
                end;
            CustAgreement."Share in property 3"::Owner2:
                begin
                    CustAgreement."Customer 2 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner2;
                    CustAgreement."Amount part 2" := OwnershipPrc;
                    CustAgreement."Contact 2" := ContactNo;

                end;
            CustAgreement."Share in property 3"::Owner3:
                begin
                    CustAgreement."Customer 3 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner3;
                    CustAgreement."Amount part 3" := OwnershipPrc;
                    CustAgreement."Contact 3" := ContactNo;
                end;
            CustAgreement."Share in property 3"::Owner4:
                begin
                    CustAgreement."Customer 4 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner4;
                    CustAgreement."Amount part 4" := OwnershipPrc;
                    CustAgreement."Contact 4" := ContactNo;
                end;
            CustAgreement."Share in property 3"::Owner5:
                begin
                    CustAgreement."Customer 5 No." := CustomerNo;
                    CustAgreement."Share in property 3" := CustAgreement."Share in property 3"::Owner5;
                    CustAgreement."Amount part 5" := OwnershipPrc;
                    CustAgreement."Contact 5" := ContactNo;
                end;
        end
    end;

    local procedure SetShareholderAttributes(var CustAgreement: Record "Customer Agreement"; ShareholderNo: Integer; CustomerNo: Code[20]; ContactNo: Code[20])
    var
        OwnershipPrc: Decimal;
    begin
        case ShareholderNo - 1 of
            CustAgreement."Share in property 3"::pNo:
                OwnershipPrc := CustAgreement."Amount part 1";
            CustAgreement."Share in property 3"::Owner2:
                OwnershipPrc := CustAgreement."Amount part 2";
            CustAgreement."Share in property 3"::Owner3:
                OwnershipPrc := CustAgreement."Amount part 3";
            CustAgreement."Share in property 3"::Owner4:
                OwnershipPrc := CustAgreement."Amount part 4";
            CustAgreement."Share in property 3"::Owner5:
                OwnershipPrc := CustAgreement."Amount part 5";
        end;
        SetShareholderAttributes(CustAgreement, ShareholderNo, CustomerNo, ContactNo, OwnershipPrc);
    end;

    local procedure SetTargetCompany(var FetchedObject: Record "CRM Prefetched Object")
    var
        BuyerToContractMap, UnitBuyerToContactMap, ObjectDataElement : Dictionary of [Text, Text];
        C, I : Integer;
        TextKey, ContactId, BuyerId, ContractId, UnitId : Text;
        DbgList: List of [Text];
        DbgVal, DbgErr : Text;
    begin
        FetchedObject.Reset();
        FetchedObject.SetFilter(Type, '%1|%2', FetchedObject.Type::Unit, FetchedObject.Type::Contract);
        if FetchedObject.FindSet() then begin
            repeat
                SetObjectDataPointer(FetchedObject.Id);

                //walkthrough of object head(I=1) and buyres (I>1)
                C := GetBuyerCount();
                if C > 0 then begin
                    for I := 1 to C + 1 do begin
                        SetObjectDataElementPointer(I);
                        case FetchedObject.Type of
                            FetchedObject.Type::Unit:
                                begin
                                    if I = 1 then begin
                                        DGet(UnitIdX, UnitId)
                                    end else begin
                                        if DGet(UnitBuyerX, BuyerId) and DGet(UnitBuyerContactX, ContactId) then begin
                                            TextKey := UnitId + '@' + BuyerId;
                                            UnitBuyerToContactMap.Add(TextKey, ContactId);
                                        end;
                                    end;
                                end;
                            FetchedObject.Type::Contract:
                                begin
                                    if I = 1 then begin
                                        DGet(ContractIdX, ContractId);
                                    end else begin
                                        DGet(ContractBuyerX, BuyerId);
                                        BuyerToContractMap.Add(BuyerId, ContractId);
                                    end;
                                end;
                        end
                    end;
                end;
            until FetchedObject.Next() = 0;
        end;

        GetCrmInteractCompanyList();
        FetchedObject.Reset();
        FetchedObject.SetFilter("Company name", '%1', '');
        if FetchedObject.FindSet() then begin
            repeat
                FetchedObject."Company name" :=
                    SuggestTargetCompany(FetchedObject, BuyerToContractMap, UnitBuyerToContactMap);
                if FetchedObject."Company name" <> '' then
                    FetchedObject.Modify();
            until FetchedObject.Next() = 0;
        end;
    end;

    local procedure SuggestTargetCompany(var FetchedObject: Record "CRM Prefetched Object";
        BuyerToContractMap: Dictionary of [Text, Text];
        UnitBuyerToContactMap: Dictionary of [Text, Text]) Result: Text[60]
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
                        foreach NewCompanyName in CrmInteractCompanyListG do begin
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
                    if ParsedObjectsG.Get(TempFetchedObject.ParentId, ObjectData) then begin
                        FetchedObject.Get(TempFetchedObject.ParentId);
                        if CrmCompany.Get(FetchedObject.ParentId) then
                            Result := CrmCompany."Company Name"
                        else
                            LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ProjectNotFoundErr, FetchedObject.ParentId));
                    end;
                    if Result = '' then begin
                        foreach NewCompanyName in CrmInteractCompanyListG do begin
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

    local procedure UpdateAgreementPostingSettings(var Agr: Record "Customer Agreement")
    var
        Cust2: Record Customer;
    begin
        if Agr."Customer No." = '' then
            exit;
        if not Cust2.Get(Agr."Customer No.") then
            exit;
        Agr."Customer Posting Group" := Cust2."Customer Posting Group";
        Agr."Gen. Bus. Posting Group" := Cust2."Gen. Bus. Posting Group";
        Agr."VAT Bus. Posting Group" := Cust2."VAT Bus. Posting Group";
    end;

    [TryFunction]
    local procedure ValidateContactData(var FetchedObject: Record "CRM Prefetched Object"; var CustTemp: Record Customer)
    var
        TempValue: Text;
        TempStr: Text;
        TempDT: DateTime;
    begin
        if not CustTemp.IsTemporary then
            Error(RecordMustBeTemporaryErr, CustTemp.TableCaption());
        CustTemp.Reset();
        CustTemp.DeleteAll();

        SetObjectDataPointer(FetchedObject.Id);
        SetObjectDataElementPointer(1);

        CustTemp.Init();
        DGet(LastNameX, TempValue);
        TempStr := TempValue;
        DGet(FirstNameX, TempValue);
        TempStr += ' ' + TempValue;
        DGet(MiddleNameX, TempValue);
        TempStr += ' ' + TempValue;
        CustTemp.Name := CopyStr(TempStr, 1, MaxStrLen(CustTemp.Name));
        if MaxStrLen(CustTemp.Name) < StrLen(TempStr) then
            CustTemp."Name 2" := CopyStr(TempStr, MaxStrLen(CustTemp.Name) + 1, MaxStrLen(CustTemp."Name 2"));
        TempStr := '';
        if DGet(PostalCityX, TempValue) then
            CustTemp.City := CopyStr(TempValue, 1, MaxStrLen(CustTemp.City));
        if DGet(CountryCodeX, TempValue) then
            CustTemp."Country/Region Code" := CopyStr(TempValue, 1, MaxStrLen(CustTemp."Country/Region Code"));
        if DGet(PostalCodeX, TempValue) then
            CustTemp."Post Code" := CopyStr(TempValue, 1, MaxStrLen(CustTemp."Post Code"));
        TempStr := '';
        if DGet(AddressLineX, TempValue) then
            TempStr := TempValue;
        TempStr := TempStr + StrSubstNo(' ,%1, %2', CustTemp.City, CustTemp."Country/Region Code");
        CustTemp.Address := CopyStr(TempStr, 1, MaxStrLen(CustTemp.Address));
        If MaxStrLen(CustTemp.Address) < StrLen(TempStr) then
            CustTemp."Address 2" := CopyStr(TempStr, MaxStrLen(CustTemp.Address) + 1, MaxStrLen(CustTemp."Address 2"));
        if DGet(ContactPhoneX, TempValue) then
            CustTemp."Phone No." := CopyStr(TempValue, 1, MaxStrLen(CustTemp."Phone No."));
        if DGet(ContactEmailX, TempValue) then
            CustTemp."E-Mail" := CopyStr(TempValue, 1, MaxStrLen(CustTemp."E-Mail"));
        CustTemp."CRM GUID" := FetchedObject.Id;
        CustTemp."Version Id" := FetchedObject."Version Id";
    end;

    [TryFunction]
    local procedure ValidateContractData(var FetchedObject: Record "CRM Prefetched Object";
        var AgrTemp: Record "Customer Agreement";
        var CustomerLocations: Dictionary of [Integer /*ShareholderNo*/, List of [Text] /*index 1 - Contact Guid; index 2 - where to search*/])
    var
        I, C, ShareHolderNo : Integer;
        TempValue, AgrType, AgrStatus : Text;
        OK, ContactIsNotFound : Boolean;
        UnitId, BuyerId, ContactId : Guid;
        CrmB: Record "CRM Buyers";
        CustNo, NavContactNo : Code[20];
        LogStatusEnum: Enum "CRM Log Status";

    begin
        if not AgrTemp.IsTemporary then
            Error(RecordMustBeTemporaryErr, AgrTemp.TableCaption());
        AgrTemp.Reset();
        AgrTemp.DeleteAll();

        SetObjectDataPointer(FetchedObject.Id);
        SetObjectDataElementPointer(1);

        AgrTemp.Init;
        DGet(ContractIdX, TempValue);
        Evaluate(AgrTemp."CRM GUID", TempValue);
        DGet(ContractNoX, TempValue);
        AgrTemp.Description := CopyStr(TempValue, 1, MaxStrLen(AgrTemp.Description));
        DGet(ContractTypeX, AgrType);
        DGet(ContractStatusX, AgrStatus);
        DGet(ContractCancelStatusX, TempValue);
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
        AgrTemp."Agreement Type" := GetAgrType(AgrType);
        AgrTemp.Status := GetAgrStatus(AgrStatus, TempValue);

        DGet(ContractIsActiveX, TempValue);
        if (TempValue.ToUpper() = 'FALSE') or (AgrTemp.Status = AgrTemp.Status::Cancelled) then
            AgrTemp.Active := false
        else
            AgrTemp.Active := true;

        DGet(ExtAgreementNoX, TempValue);
        AgrTemp."External Agreement No." := CopyStr(TempValue, 1, MaxStrLen(AgrTemp."External Agreement No."));
        //FullAgreementNo to-do
        DGet(AgreementAmountX, TempValue);
        OK := Evaluate(AgrTemp."Agreement Amount", TempValue, 9);
        AgrTemp."Apartment Amount" := AgrTemp."Agreement Amount";
        if DGet(FinishingInclX, TempValue) then
            Ok := Evaluate(AgrTemp."Including Finishing Price", TempValue, 9);
        DGet(ContractUnitIdX, TempValue);
        Evaluate(UnitId, TempValue);

        C := GetBuyerCount();
        if (C = 0) and (AgrTemp."Agreement Type" <> AgrTemp."Agreement Type"::"Reserving Agreement") then
            Error(ContractBuyersNotFoundErr);

        if (C = 0) or (AgrTemp."Agreement Type" = AgrTemp."Agreement Type"::"Reserving Agreement") then begin
            CrmB.SetRange("Unit Guid", UnitId);
            CrmB.FindFirst();
            AgrTemp."Object of Investing" := CrmB."Investment Object";
            if CrmB."Agreement Start" <> 0D then begin
                AgrTemp."Agreement Date" := CrmB."Agreement Start";
                AgrTemp."Starting Date" := CrmB."Agreement Start";
                AgrTemp."Expire Date" := CrmB."Agreement End";
            end;
            CustNo := FindCustomer(1, CrmB."Reserving Contact Guid", CrmB."Buyer Guid", true, CustomerLocations);
            if not CustomerLocations.ContainsKey(1) then
                Error(ContractContactNotFound,
                    CrmB."Reserving Contact Guid",
                    CrmB."Unit Guid",
                    Crmb."Buyer Guid")
            else begin
                if CustNo <> '' then
                    NavContactNo := GetContactFromCustomer(CustNo)
                else begin
                    CustNo := '1';
                    NavContactNo := CustNo;
                end;
                SetShareholderAttributes(AgrTemp, 1, CustNo, NavContactNo, CrmB."Ownership Percentage")
            end;
            if CrmB."Agreement Start" <> 0D then begin
                AgrTemp."Agreement Date" := CrmB."Agreement Start";
                AgrTemp."Starting Date" := CrmB."Agreement Start";
                AgrTemp."Expire Date" := CrmB."Agreement End";
            end;
            AgrTemp.Insert();
            exit;
        end else begin
            ShareHolderNo := 0;
            for I := 2 to C + 1 do begin
                SetObjectDataElementPointer(I);
                DGet(ContractBuyerX, TempValue);
                Evaluate(BuyerId, TempValue);
                CrmB.Get(UnitId, BuyerId);
                if CrmB."Buyer Is Active" then begin
                    ShareHolderNo += 1;
                    AgrTemp."Object of Investing" := CrmB."Investment Object";
                    if CrmB."Agreement Start" <> 0D then begin
                        AgrTemp."Agreement Date" := CrmB."Agreement Start";
                        AgrTemp."Starting Date" := CrmB."Agreement Start";
                        AgrTemp."Expire Date" := CrmB."Agreement End";
                    end;
                    ContactId := CrmB."Contact Guid";
                    CustNo := FindCustomer(ShareHolderNo, ContactId, BuyerId, false, CustomerLocations);
                    if not CustomerLocations.ContainsKey(ShareHolderNo) then begin
                        LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ContractContactNotFound, ContactId, UnitId, BuyerId));
                        ContactIsNotFound := true;
                    end else begin
                        if CustNo <> '' then
                            NavContactNo := GetContactFromCustomer(CustNo)
                        else begin
                            CustNo := Format(ShareHolderNo);
                            NavContactNo := CustNo;
                        end;
                        SetShareholderAttributes(AgrTemp, ShareHolderNo, CustNo, NavContactNo, CrmB."Ownership Percentage")
                    end;
                end;
                if ShareHolderNo > 5 then
                    break;
            end;
            if ContactIsNotFound then
                Error(ContractNotCreatedErr);
        end;

        AgrTemp."CRM GUID" := FetchedObject.Id;
        AgrTemp."Version Id" := FetchedObject."Version Id";
    end;

    [TryFunction]
    local procedure ValidateContractData2(var FetchedObject: Record "CRM Prefetched Object"; var AgrTemp: Record "Customer Agreement")
    var
        Agr, Agr2 : Record "Customer Agreement";
        AgrNo, CustomerNo : Code[20];
    begin
        Agr.SetRange("CRM GUID", FetchedObject.Id);
        Agr.SetFilter("Agreement Type", '<>%1', Agr."Agreement Type"::Service);
        if Agr.IsEmpty then
            exit;
        Agr.FindFirst();
        if AgrTemp."Customer No." = Agr."Customer No." then
            exit;

        AgrNo := Agr."No.";
        CustomerNo := Agr."Customer No.";
        if Agr.Get(AgrTemp."Customer No.", AgrNo) then
            Error(StrSubstNo(ContractAlreadyLinkedErr, CustomerNo, AgrTemp."Customer No."));

    end;

    [TryFunction]
    local procedure ValidateUnitData(var FetchedObject: Record "CRM Prefetched Object"; var CrmBTemp: Record "CRM Buyers"; var ApartmentTemp: Record "Investment Object")
    var
        TempValue: Text;
        TempDT: DateTime;
        I, C : integer;
        OK: Boolean;
        ExpectedRegPeriod: Integer;
        AgrStartDate, AgrEndDate : Date;
        LogStatusEnum: Enum "CRM Log Status";

    begin
        if not CrmBTemp.IsTemporary then
            Error(RecordMustBeTemporaryErr, CrmBTemp.TableCaption());
        CrmBTemp.Reset();
        CrmBTemp.DeleteAll();

        if not ApartmentTemp.IsTemporary then
            Error(RecordMustBeTemporaryErr, ApartmentTemp.TableCaption());
        ApartmentTemp.Reset();
        ApartmentTemp.DeleteAll();

        SetObjectDataPointer(FetchedObject.Id);
        SetObjectDataElementPointer(1);

        CrmBTemp.Init();
        CrmBTemp."Unit Guid" := FetchedObject.Id;
        CrmBTemp."Version Id" := FetchedObject."Version Id";
        CrmBTemp."Project Id" := FetchedObject.ParentId;
        if DGet(ReservingContactX, TempValue) then
            Evaluate(CrmBTemp."Reserving Contact Guid", TempValue);
        if DGet(InvestmentObjectX, TempValue) then begin
            CrmBTemp."Investment Object" := TempValue;
            ApartmentTemp.Init();
            ApartmentTemp."Object No." := CrmBTemp."Investment Object";
            if DGet(BlockNumberX, TempValue) then
                ApartmentTemp.Description := TempValue.Trim();
            if DGet(ApartmentNumberX, TempValue) then begin
                if (ApartmentTemp.Description <> '') and (not ApartmentTemp.Description.EndsWith(' ')) then
                    ApartmentTemp.Description += ' ';
                ApartmentTemp.Description += TempValue.Trim();
            end;
            if DGet(ApartmentOriginTypeX, TempValue) then begin
                if not Evaluate(ApartmentTemp.Type, TempValue) then
                    LogEvent(FetchedObject, LogStatusEnum::Warning, StrSubstNo(UnknownInvestObjectTypeValueErr, TempValue));
            end;

            if DGet(ApartmentUnitAreaM2X, TempValue) then
                OK := Evaluate(ApartmentTemp."Total Area (Project)", TempValue, 9);
            ApartmentTemp.Insert();
        end;

        C := GetBuyerCount();
        if C = 0 then begin
            CrmBTemp.Insert();
            exit;
        end;

        ExpectedRegPeriod := 0;
        if DGet(ExpectedRegDateX, TempValue) then
            Evaluate(ExpectedRegPeriod, TempValue, 9);
        AgrStartDate := 0D;
        if DGet(ActualDateX, TempValue) then begin
            if Evaluate(TempDT, TempValue, 9) then
                AgrStartDate := DT2Date(TempDT) - ExpectedRegPeriod;
        end;
        AgrEndDate := 0D;
        if DGet(ExpectedDateX, TempValue) then begin
            if Evaluate(TempDT, TempValue, 9) then
                AgrEndDate := DT2Date(TempDT);
        end;

        for I := 2 to C + 1 do begin
            SetObjectDataElementPointer(I);
            DGet(UnitBuyerX, TempValue);
            Evaluate(CrmBTemp."Buyer Guid", TempValue);
            if DGet(UnitBuyerContactX, TempValue) then
                Evaluate(CrmBTemp."Contact Guid", TempValue);
            if DGet(UnitBuyerContractX, TempValue) then
                Evaluate(CrmBTemp."Contract Guid", TempValue);
            if DGet(UnitBuyerOwnershipPrcX, TempValue) then
                Evaluate(CrmBTemp."Ownership Percentage", TempValue, 9)
            Else
                CrmBTemp."Ownership Percentage" := 100;
            CrmBTemp."Buyer Is Active" := true;
            if DGet(UnitBuyerIsActiveX, TempValue) then begin
                if TempValue.ToUpper() = 'FALSE' then
                    CrmBTemp."Buyer Is Active" := false;
            end;
            if CrmBTemp."Buyer Is Active" then begin
                CrmBTemp."Expected Registration Period" := ExpectedRegPeriod;
                CrmBTemp."Agreement Start" := AgrStartDate;
                CrmBTemp."Agreement End" := AgrEndDate;
            end;
            CrmBTemp."Version Id" := FetchedObject."Version Id";
            CrmBTemp.Insert();
        end;
    end;


    local procedure WriteContactToDB(var FetchedObject: Record "CRM Prefetched Object";
        CustTemp: Record Customer;
        TargetCompanyName: Text[60];
        ImportActionEnum: Enum "CRM Import Action") Result: Code[20]
    var
        Customer: Record Customer;
        CrmSetup: Record "CRM Integration Setup";
        UpdateContFromCust: Codeunit "CustCont-Update";
        ContBusRelation: Record "Contact Business Relation";
        LogStatusEnum: Enum "CRM Log Status";
    begin

        if TargetCompanyName = '' then
            TargetCompanyName := CompanyName();

        if (ImportActionEnum = ImportActionEnum::Create) and (TargetCompanyName <> CompanyName()) then
            Error('DBG: WriteContactToDB - Try to insert Contact into Company outside the current!');

        if TargetCompanyName <> CompanyName() then
            Customer.ChangeCompany(TargetCompanyName);

        Customer.Reset();
        case ImportActionEnum of
            ImportActionEnum::Create:
                begin
                    Customer.Init();
                    Customer."No." := '';
                    Customer.Insert(true);
                end;
            ImportActionEnum::Update:
                begin
                    Customer.SetRange("CRM GUID", FetchedObject.id);
                    Customer.SetRange("Version Id");
                    Customer.FindFirst();
                end;
            else
                Error(ImportActionNotAllowedErr, ImportActionEnum);
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
        if ImportActionEnum = ImportActionEnum::Create then begin
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

        LogEvent(FetchedObject, TargetCompanyName, LogStatusEnum::Done, ImportActionEnum, StrSubstNo(ContactProcessedMsg, Customer."No."), '');
    end;


    local procedure WriteContractToDB(var FetchedObject: Record "CRM Prefetched Object";
        var AgrTemp: Record "Customer Agreement";
        CustomerLocations: Dictionary of [Integer /*ShareholderNo*/, List of [Text]];
        ImportActionEnum: Enum "CRM Import Action") Result: Code[20]
    var
        ShareHolderNo: Integer;
        Agr, Agr2 : Record "Customer Agreement";
        CrmB: Record "CRM Buyers";
        CLE: Record "Cust. Ledger Entry";
        LogStatusEnum: Enum "CRM Log Status";
        Msg, MsgMain : Text;
        OldCustNo: Code[20];
        BuyerId: Guid;
        SearchParamList: List of [Text];
    begin
        case ImportActionEnum of
            ImportActionEnum::Create:
                begin
                    Agr := AgrTemp;
                    Agr."No." := '';
                    Agr.Insert(true);
                    UpdateAgreementPostingSettings(Agr);
                    MsgMain := ContractCreatedMsg;
                end;
            ImportActionEnum::Update:
                begin
                    Agr.SetRange("CRM GUID", AgrTemp."CRM GUID");
                    Agr.SetFilter("Agreement Type", '<>%1', Agr."Agreement Type"::Service);
                    Agr.FindFirst();
                    if Agr."Customer No." <> AgrTemp."Customer No." then begin
                        OldCustNo := Agr."Customer No.";
                        Agr.Rename(AgrTemp."Customer No.", Agr."No.");
                        UpdateAgreementPostingSettings(Agr);
                        Agr."Old Customer No." := OldCustNo;
                        Agr."Contact 1" := GetContactFromCustomer(Agr."Customer No.");
                        Agr.Modify(true);
                        CLE.SetCurrentKey("Customer No.");
                        Cle.SetRange("Customer No.", Agr."Customer No.");
                        CLE.SetRange("Agreement No.", Agr."No.");
                        CLE.ModifyAll("Customer No.", AgrTemp."Customer No.", false);
                    end;

                    MsgMain := ContractUpdatedMsg;
                end;
            else begin
                    LogEvent(FetchedObject, LogStatusEnum::Error, ImportActionNotAllowedErr);
                    exit;
                end;
        end;

        Agr.Validate(Agr."Agreement Type", AgrTemp."Agreement Type");
        Agr.Validate(Agr.Status, AgrTemp.Status);
        Agr.Validate(Agr.Active, AgrTemp.Active);
        Agr.Validate(Agr."Customer 2 No.", AgrTemp."Customer 2 No.");
        Agr.Validate(Agr."Customer 3 No.", AgrTemp."Customer 3 No.");
        Agr.Validate(Agr."Customer 4 No.", AgrTemp."Customer 4 No.");
        Agr.Validate(Agr."Customer 5 No.", AgrTemp."Customer 5 No.");
        Agr.Validate(Agr."Contact 1", AgrTemp."Contact 1");
        Agr.Validate(Agr."Contact 2", AgrTemp."Contact 2");
        Agr.Validate(Agr."Contact 3", AgrTemp."Contact 3");
        Agr.Validate(Agr."Contact 4", AgrTemp."Contact 4");
        Agr.Validate(Agr."Contact 5", AgrTemp."Contact 5");
        Agr.Validate(Agr."External Agreement No.", AgrTemp."External Agreement No.");
        //Agr.Validate(Agr."Full Agreement No.", AgrTemp."Full Agreement No.");
        Agr.Validate(Agr."Share in property 3", AgrTemp."Share in property 3");
        Agr.Validate(Agr."Amount part 1", AgrTemp."Amount part 1");
        Agr.Validate(Agr."Amount part 2", AgrTemp."Amount part 2");
        Agr.Validate(Agr."Amount part 3", AgrTemp."Amount part 3");
        Agr.Validate(Agr."Amount part 4", AgrTemp."Amount part 4");
        Agr.Validate(Agr."Amount part 5", AgrTemp."Amount part 5");
        Agr."Object of Investing" := AgrTemp."Object of Investing";
        Agr.Validate("Agreement Amount", AgrTemp."Agreement Amount");
        Agr.Validate("Apartment Amount", AgrTemp."Apartment Amount");
        Agr.Validate("Including Finishing Price", AgrTemp."Including Finishing Price");
        Agr."Agreement Date" := AgrTemp."Agreement Date";
        Agr."Starting Date" := AgrTemp."Starting Date";
        Agr."Expire Date" := AgrTemp."Expire Date";
        Agr."Version Id" := FetchedObject."Version Id";
        Agr.Modify(true);

        CreateServiceAgreement(FetchedObject, Agr, 2);
        CreateServiceAgreement(FetchedObject, Agr, 3);
        CreateServiceAgreement(FetchedObject, Agr, 4);
        CreateServiceAgreement(FetchedObject, Agr, 5);

        foreach ShareHolderNo in CustomerLocations.Keys() do begin
            CustomerLocations.Get(ShareHolderNo, SearchParamList);
            if SearchParamList.Contains(CustomerSearchReserveContact) then begin
                CrmB.SetRange("Unit Guid", FetchedObject.ParentId);
                Crmb.FindFirst();
                CrmB."Reserving Contract Guid" := FetchedObject.Id;
                CrmB.Modify(true);
            end else begin
                Evaluate(BuyerId, SearchParamList.Get(4));
                CrmB.Get(FetchedObject.ParentId, BuyerId);
                if CrmB."Contract Guid" <> FetchedObject.Id then begin
                    CrmB."Contract Guid" := FetchedObject.Id;
                    CrmB.Modify(true);
                end;
            end;
        end;

        LogEvent(FetchedObject, LogStatusEnum::Done,
            StrSubstNo(MsgMain,
                Agr."No.",
                Agr.FieldCaption("Agreement Type"),
                Agr."Agreement Type",
                Agr.FieldCaption(Status),
                Agr.Status));
    end;


    local procedure WriteUnitToDB(var FetchedObject: Record "CRM Prefetched Object"; var CrmBTemp: Record "CRM Buyers"; var ApartmentTemp: Record "Investment Object"; ImportActionEnum: Enum "CRM Import Action")
    var
        CrmB: Record "CRM Buyers";
        Apartment: Record "Investment Object";
        LogStatusEnum: Enum "CRM Log Status";
        ImportAction: Enum "CRM Import Action";

    begin
        ApartmentTemp.Reset();
        if ApartmentTemp.FindSet() then begin
            repeat
                Apartment := ApartmentTemp;
                if Apartment.Insert(true) then begin
                    LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(InvestmentObjectCreatedMsg, Apartment."Object No."));
                end else begin
                    Apartment.Modify(True);
                    LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(InvestmentObjectUpdatedMsg, Apartment."Object No."));
                end;
            until ApartmentTemp.Next() = 0;
        end;

        CrmB.Reset();
        CrmB.SetRange("Unit Guid", FetchedObject.Id);
        CrmB.DeleteAll(true);

        CrmBTemp.Reset();
        if CrmBTemp.FindSet() then begin
            repeat
                CrmB := CrmBTemp;
                CrmB.Insert(true);
                case ImportActionEnum of
                    ImportActionEnum::Create:
                        LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(UnitCreatedMsg, CrmB."Buyer Guid"));
                    ImportActionEnum::Update:
                        LogEvent(FetchedObject, LogStatusEnum::Done, StrSubstNo(UnitUpdatedMsg, CrmB."Buyer Guid"));
                    else
                        LogEvent(FetchedObject, LogStatusEnum::Error, StrSubstNo(ImportActionNotAllowedErr, ImportActionEnum));
                end

            until CrmBTemp.Next() = 0;
        end;
    end;


    [TryFunction]
    local procedure XmlNodeExists(XmlElem: XmlElement; XPath: Text)
    var
        TempXmlNode: XmlNode;
    begin
        XmlElem.SelectSingleNode(XPath, TempXmlNode);
    end;


    local procedure GetMsgBuffFieldRef(JsonField: Enum "Crm Json Field"; var NewFieldRef: FieldRef)
    var
        OrdinalValue, MsgBuffFieldNo : Integer;
    begin
        OrdinalValue := JsonField.AsInteger();
        MsgBuffFieldNo := OrdinalValue mod 1000;
        if OrdinalValue in [4000 .. 4999] then
            NewFieldRef := SubMsgBuffRecRefG.Field(MsgBuffFieldNo)
        else
            NewFieldRef := MsgBuffRecRefG.Field(MsgBuffFieldNo)
    end;

    local procedure GetValue(JsonField: Enum "Crm Json Field"; var NewValue: Text)
    var
        FldRef: FieldRef;
    begin
        GetMsgBuffFieldRef(JsonField, FldRef);
        if FldRef.Type <> FldRef.Type::Text then
            Error(FieldTypeMismatchErr, JsonField, FldRef.Type::Text);
        NewValue := FldRef.Value();
    end;

    local procedure GetValue(JsonField: Enum "Crm Json Field"; var NewValue: Guid)
    var
        FldRef: FieldRef;
    begin
        GetMsgBuffFieldRef(JsonField, FldRef);
        if FldRef.Type <> FldRef.Type::Guid then
            Error(FieldTypeMismatchErr, JsonField, FldRef.Type::Guid);
        NewValue := FldRef.Value();
    end;

    local procedure GetValue(JsonField: Enum "Crm Json Field"; var NewValue: Decimal)
    var
        FldRef: FieldRef;
    begin
        GetMsgBuffFieldRef(JsonField, FldRef);
        if FldRef.Type <> FldRef.Type::Decimal then
            Error(FieldTypeMismatchErr, JsonField, FldRef.Type::Decimal);
        NewValue := FldRef.Value();
    end;

    local procedure GetValue(JsonField: Enum "Crm Json Field"; var NewValue: Boolean)
    var
        FldRef: FieldRef;
    begin
        GetMsgBuffFieldRef(JsonField, FldRef);
        if FldRef.Type <> FldRef.Type::Boolean then
            Error(FieldTypeMismatchErr, JsonField, FldRef.Type::Boolean);
        NewValue := FldRef.Value();
    end;

}
