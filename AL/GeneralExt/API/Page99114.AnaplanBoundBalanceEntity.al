page 99114 "Anaplan Bound Balance Entity"
{
    PageType = API;

    APIPublisher = 'bc';
    APIGroup = 'anaplan';
    APIVersion = 'beta';
    EntityCaption = 'Bound Balance RU', Locked = true;
    EntitySetCaption = 'Bound Balance RU', Locked = true;
    EntityName = 'boundBalanceRu';
    EntitySetName = 'boundBalanceRu';

    ODataKeyFields = SystemId;
    SourceTable = "Anaplan Entity";

    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;

                }

                field(verificationNumber; Rec."Verification Number")
                {

                }

                field(verificationType; Rec."Verification Type")
                {

                }

                field(dateTimeUploading; Rec."Date Time Uploading")
                {

                }

                field(erpProject; Rec."ERP Project")
                {

                }

                field(legalEntity; Rec."Legal Entity")
                {

                }

                field(account; Rec.Account)
                {

                }

                field(activity; Rec.Activity)
                {

                }

                field(accountingPeriod; Rec."Accounting Period")
                {

                }


                field(postingDate; Rec."Posting Date")
                {

                }

                field(baseAmount; Rec."Base Amount")
                {

                }

                field(baseAmountSign; Rec."Base Amount Sign")
                {

                }

                field(currencyCode; Rec."Currency Code")
                {

                }

                field(agreementNo; Rec."Agreement No.")
                {

                }

                field(externalAgreement; Rec."External Agreement No.")
                {

                }

                field(supplier; Rec."Supplier No.")
                {

                }

                field(supplierName; Rec."Supplier Name")
                {

                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //to-do
    end;
}
