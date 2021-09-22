tableextension 70611 "Dimension Value (Req)" extends "Dimension Value"
{
    fields
    {
        field(50005; "Cost Holder"; Code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Cost Holder';
            TableRelation = "User Setup";

            trigger OnValidate()
            begin
                CheckRequestDimensions(0);
            end;
        }
        field(50020; "Cost Code Type"; Option)
        {
            Description = 'NC 51373 AB';
            Caption = 'Cost Code Type';
            OptionCaption = ' ,Production,Development,Admin';
            OptionMembers = " ",Production,Development,Admin;

            trigger OnValidate()
            begin
                CheckRequestDimensions(0);
            end;
        }
        field(50021; "Development Cost Place Holder"; code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Development Cost Place Holder';
            TableRelation = "User Setup";

            trigger OnValidate()
            begin
                CheckRequestDimensions(1);
            end;
        }
        field(50022; "Production Cost Place Holder"; code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Production Cost Place Holder';
            TableRelation = "User Setup";

            trigger OnValidate()
            begin
                CheckRequestDimensions(1);
            end;
        }
        field(50023; "Admin Cost Place Holder"; code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Admin Cost Place Holder';
            TableRelation = "User Setup";

            trigger OnValidate()
            begin
                CheckRequestDimensions(1);
            end;
        }
        field(50024; "Check Address Dimension"; Boolean)
        {
            Description = 'NC 53376 AB';
            Caption = 'Check Address Dimension';

            trigger OnValidate()
            begin
                CheckRequestDimensions(2);
            end;
        }
    }

    var
        PurchSetup: Record "Purchases & Payables Setup";

    local procedure CheckRequestDimensions(DimType: Option "CostCode","CostPlace","Address")
    begin
        PurchSetup.Get();
        case DimType of
            DimType::CostCode:
                begin
                    PurchSetup.TestField("Cost Code Dimension");
                    TestField("Dimension Code", PurchSetup."Cost Code Dimension");
                end;
            DimType::CostPlace:
                begin
                    PurchSetup.TestField("Cost Place Dimension");
                    TestField("Dimension Code", PurchSetup."Cost Place Dimension");
                end;
            DimType::Address:
                begin
                    PurchSetup.TestField("Address Dimension");
                    CheckRequestDimensions(1);
                end;
        end;
    end;
}