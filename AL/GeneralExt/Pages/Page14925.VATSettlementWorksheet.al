pageextension 94925 "VAT Settlement Worksheet GE" extends "VAT Settlement Worksheet"
{
    layout
    {
        addafter(Type)
        {
            field(dim1Filter; dim1Filter)
            {
                ApplicationArea = All;
                CaptionClass = '1,3,1';
                trigger OnValidate()
                begin
                    rec.setfilter("Global Dimension 1 Filter", dim1Filter);
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    dimVal: record "Dimension Value";
                begin
                    dimVal.reset();
                    dimVal.setrange("Global Dimension No.", 1);
                    if (page.runmodal(0, dimval) = action::lookupok) then begin
                        dim1Filter += dimVal.Code;
                        rec.setfilter("Global Dimension 1 Filter", dim1Filter);
                    end;
                end;
            }
            field(dim2Filter; dim2Filter)
            {
                ApplicationArea = All;
                CaptionClass = '1,3,2';
                trigger OnValidate()
                begin
                    rec.setfilter("Global Dimension 2 Filter", dim2Filter);
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    dimVal: record "Dimension Value";
                begin
                    dimVal.reset();
                    dimVal.setrange("Global Dimension No.", 2);
                    if (page.runmodal(0, dimval) = action::lookupok) then begin
                        dim2Filter += dimVal.Code;
                        rec.setfilter("Global Dimension 2 Filter", dim2Filter);
                    end;
                end;
            }

            field(costType; costType)
            {
                ApplicationArea = All;
                Caption = 'Cost Code Type Filter';
                OptionCaption = ' ,Production,Development,Admin';

                trigger OnValidate()
                begin
                    rec.setfilter("Cost Code Type Filter", format(costType));
                end;
            }

        }
        addafter("Document No.")
        {
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = Dimensions;
            }
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = Dimensions;
            }
            field("Cost Code Type"; Rec."Cost Code Type")
            {
                ApplicationArea = Dimensions;
            }
        }
        addlast(Control1470000)
        {
            field("VAT Allocation"; Rec."VAT Allocation")
            {
                ApplicationArea = All;
            }
        }


    }
    var
        dim1Filter, dim2Filter : code[250];
        costType: option;
}
