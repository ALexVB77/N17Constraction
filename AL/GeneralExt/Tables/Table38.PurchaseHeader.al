tableextension 80038 "Purchase Header (Ext)" extends "Purchase Header"
{
    fields
    {
        field(50002; "Inv.-Fact. is Received"; Boolean)
        {
            Caption = 'Inv.-Fact. is Received';
            Description = 'NC 50280 OA';
        }
        field(50003; "Act is Received"; Boolean)
        {
            Caption = 'Act is Received';
            Description = 'NC 50280 OA';
        }
        field(60088; "Original Company"; Code[2])
        {
            Description = 'NC 51432 AP';
            Caption = 'Original Company';
        }
    }

    local procedure UpdateCF()
    var
        PL: record "Purchase Line";
        PBE: record "Projects Budget Entry";
    begin
        //NC 27251 HR beg
        IF "Due Date" = 0D THEN
            EXIT;
        PL.SETRANGE("Document Type", "Document Type");
        PL.SETRANGE("Document No.", "No.");
        IF PL.FINDSET THEN BEGIN
            REPEAT
                IF PL."Forecast Entry" <> 0 THEN BEGIN
                    PBE.SETRANGE("Entry No.", PL."Forecast Entry");
                    IF PBE.FINDFIRST THEN BEGIN
                        PBE.VALIDATE(Date, "Due Date");
                        PBE.VALIDATE("Problem Pmt. Document", "Problem Document");
                        PBE.MODIFY(TRUE);
                    END;
                END;
            UNTIL PL.NEXT = 0;
        END;
        //NC 27251 HR end
    end;

    procedure HasBoundedCashFlows(): Boolean
    var
        PurchLine3: record "Purchase Line";
    begin
        //NC 29594 HR beg
        PurchLine3.SETRANGE("Document Type", "Document Type");
        PurchLine3.SETRANGE("Document No.", "No.");
        PurchLine3.SETFILTER("Forecast Entry", '<>0');
        EXIT(NOT PurchLine3.ISEMPTY);
        //NC 29594 HR end
    end;

    procedure SetPaymentInvPaidStatus(NewPaid: Boolean)
    var
        gvduERPC: codeunit "ERPC Funtions";
    begin
        IF NewPaid THEN BEGIN
            CalcFields("Paid Date Fact");
            TESTFIELD("Paid Date Fact");
            gvduERPC.PostForecastEntry(Rec);
        END ELSE BEGIN
            gvduERPC.UnpostForecastEntry(Rec);
        END;
    end;

}