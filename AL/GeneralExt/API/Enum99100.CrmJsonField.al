enum 99100 "Crm Json Field"
{
    Extensible = true;

    //Contact
    value(1010; "Contact.objectType") { }
    value(1050; "Contact.objectId") { }
    value(1014; "Contact.lastName") { }
    value(1015; "Contact.firstName") { }
    value(1016; "Contact.middleName") { }
    value(1011; "Contact.postalCity") { }
    value(1012; "Contact.countryCode") { }
    value(1013; "Contact.postalCode") { }
    value(1019; "Contact.address") { }
    value(1017; "Contact.phone") { }
    value(1018; "Contact.email") { }


    //contract
    value(2010; "Contract.objectType") { }
    value(2050; "Contract.objectId") { }
    value(2051; "Contract.unitId") { }
    value(2011; "Contract.number") { }
    value(2012; "Contract.type") { }
    value(2013; "Contract.status") { }
    value(2014; "Contract.cancelStatus") { }
    value(2040; "Contract.isActive") { }
    value(2015; "Contract.externalNo") { }
    value(2030; "Contract.amount") { }
    value(2041; "Contract.finishingIncl") { }
    value(2019; "Contract.buyers") { }

    //unit
    value(3010; "Unit.objectType") { }
    value(3050; "Unit.objectId") { }
    value(3051; "Unit.projectId") { }
    value(3052; "Unit.reservingContactId") { }
    value(3011; "Unit.investmentObjectCode") { }
    value(3014; "Unit.investmentObjectDescription") { }
    value(3012; "Unit.investmentObjectType") { }
    value(3030; "Unit.investmentObjectArea") { }
    value(3060; "Unit.expectedRegDate") { }
    value(3061; "Unit.actualDate") { }
    value(3062; "Unit.expectedDate") { }

    //Unit buyer
    value(4050; "UnitBuyer.buyerId") { }
    value(4051; "UnitBuyer.contactId") { }
    value(4052; "UnitBuyer.contractId") { }
    value(4030; "UnitBuyer.ownershipPrc") { }
    value(4040; "UnitBuyer.buyerIsActive") { }


}
