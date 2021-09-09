page 99100 "API Car Brand"
{
    PageType = API;

    APIVersion = 'beta';
    APIPublisher = 'bonava';
    APIGroup = 'crm';

    EntityCaption = 'CarBrand';
    EntitySetCaption = 'CarBrands';
    EntityName = 'carBrand';
    EntitySetName = 'carBrands';

    ODataKeyFields = SystemId;
    SourceTable = "Car Brand";

    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(country; Rec.Country)
                {
                    Caption = 'Country';
                }
                part(carModels; "API Car Model")
                {
                    Caption = 'Car Models';
                    EntityName = 'carModel';
                    EntitySetName = 'carModels';
                    SubPageLink = "Brand Id" = Field(SystemId);
                }
            }
        }
    }
}
