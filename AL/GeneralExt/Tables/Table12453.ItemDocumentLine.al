tableextension 92453 "Item Document Line GE" extends "Item Document Line"
{
    fields
    {
        field(50000; "Change From Giv. Prod. Order"; Boolean)
        {
            Caption = 'Change From Giv. Prod. Order';
            DataClassification = CustomerContent;
        }
        field(70040; "Utilities Dim. Value Code"; code[20])
        {
            Caption = 'Utilities Dim. Value Code';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                glSetup: record "General Ledger Setup";
                dimValue: record "Dimension Value";
            begin

                //NC 46674 > KGT
                GLSetup.GET;
                GLSetup.TESTFIELD("Utilities Dimension Code");
                DimValue.FILTERGROUP(2);
                DimValue.SETRANGE("Dimension Code", GLSetup."Utilities Dimension Code");
                DimValue.SETRANGE(Blocked, FALSE);
                DimValue.FILTERGROUP(0);

                IF Page.RUNMODAL(0, DimValue) = ACTION::LookupOK THEN BEGIN
                    //"Utilities Dim. Value Code" := DimValue.Code;
                    VALIDATE("Utilities Dim. Value Code", DimValue.Code);
                END;
                //NC 46674 < KGT
            end;

            trigger OnValidate()
            var
                dimMgt: Codeunit "Dimension Management (Ext)";
                glSetup: record "General Ledger Setup";
            begin

                GLSetup.GET;
                GLSetup.TESTFIELD("Utilities Dimension Code");
                dimMgt.valDimValue(glsetup."Utilities Dimension Code", rec."Utilities Dim. Value Code", rec."Dimension Set ID");
                rec.modify();
            end;
        }
    }
    var

        ChangeFromGivProdOrder: Boolean;

    procedure SetChangeFromGivProdOrder(ChangeFromDivProdOrderNew: boolean)
    begin

        // SWC816 AK 120516 >>    
        ChangeFromGivProdOrder := ChangeFromDivProdOrderNew;
        // SWC816 AK 120516 <<

    end;
}
