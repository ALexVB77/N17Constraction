tableextension 80122 "Purch. Inv. Header (Ext)" extends "Purch. Inv. Header"
{
    fields
    {
        field(60010; "Giv. Prod. Order No."; Code[20])
        {
            Caption = 'Giv. Prod. Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Giv. Prod. Order";
        }
    }
    procedure GivProdOrderCheckDocDim(RcptActNo: code[20]; RcptActPosted: boolean)
    var
        GLSetup: Record "General Ledger Setup";
        DocDimHdrActUnposted: Record "Dimension Set Entry";
        DocDimHdrActPosted: Record "Dimension Set Entry";
        DocDimHdr: Record "Dimension Set Entry";
        DocDimLine: Record "Dimension Set Entry";
        DocLine: Record "Purch. Inv. Line";
        i: Integer;
        DimCode: Code[20];
        IsError: Boolean;
        Dimension: Record Dimension;
        irh: Record "Item Receipt Header";
        idh: Record "Item Document Header";
        pih: Record "Purch. Inv. Header";
        pil: Record "Purch. Inv. Line";
        locLabel001: label 'Измерение "%1" в заголовке и в строке %2 счета %3 отличается';
        locLabel002: label 'Измерение "%1" в акте оприходования %2 и в счете %3 отличается';
    begin

        // SWC816 AK 120516 >>
        IF RcptActPosted THEN BEGIN
            irh.get(RcptActNo);

            /*
            DocDimHdrActPosted.RESET;
            DocDimHdrActPosted.SETRANGE("Table ID", DATABASE::"Item Receipt Header");
            DocDimHdrActPosted.SETRANGE("Document No.", RcptActNo);
            */
        END
        ELSE BEGIN
            idh.get(idh."Document Type"::Receipt, RcptActNo);
            /*
            DocDimHdrActUnposted.RESET;
            DocDimHdrActUnposted.SETRANGE("Table ID", DATABASE::"Item Document Header");
            DocDimHdrActUnposted.SETRANGE("Document Type", DocDimHdrActUnposted."Document Type"::"Item Receipt");
            DocDimHdrActUnposted.SETRANGE("Document No.", RcptActNo);
            */
        END;
        pih.get("No.");
        /*
        DocDimHdr.RESET;
        DocDimHdr.SETRANGE("Table ID", DATABASE::"Purch. Inv. Header");
        DocDimHdr.SETRANGE("Document No.", "No.");

        DocDimLine.RESET;
        DocDimLine.SETRANGE("Table ID", DATABASE::"Purch. Inv. Line");
        DocDimLine.SETRANGE("Document No.", "No.");
        */
        GLSetup.GET;
        DocLine.RESET;
        DocLine.SETRANGE("Document No.", "No.");
        DocLine.SETFILTER("No.", '<>%1', '');
        IF DocLine.FINDSET THEN
            REPEAT
                FOR i := 1 TO 2 DO BEGIN
                    CASE i OF
                        1:
                            DimCode := GLSetup."Global Dimension 1 Code";
                        2:
                            DimCode := GLSetup."Global Dimension 2 Code";
                        3:
                            DimCode := GLSetup."Cost Type Dimension Code";
                    END;

                    Dimension.GET(DimCode);

                    if (not DocDimHdr.get(pih."Dimension Set ID", DimCode)) then DocDimHdr."Dimension Value Code" := '';
                    IF NOT DocDimLine.get(DocLine."Dimension Set ID", DimCode) THEN
                        DocDimLine."Dimension Value Code" := '';

                    /*
                    DocDimHdr.SETRANGE("Line No.", 0);
                    DocDimHdr.SETRANGE("Dimension Code", DimCode);
                    IF NOT DocDimHdr.FINDFIRST THEN
                        DocDimHdr."Dimension Value Code" := '';

                    DocDimLine.SETRANGE("Line No.", DocLine."Line No.");
                    DocDimLine.SETRANGE("Dimension Code", DimCode);
                    IF NOT DocDimLine.FINDFIRST THEN
                        DocDimLine."Dimension Value Code" := '';
                    */
                    IF DocDimHdr."Dimension Value Code" <> DocDimLine."Dimension Value Code" THEN
                        ERROR(locLabel001,
                          Dimension.Name, DocLine."Line No.", "No.");

                    IsError := FALSE;
                    IF RcptActPosted THEN BEGIN
                        //DocDimHdrActPosted.SETRANGE("Line No.", 0);
                        //DocDimHdrActPosted.SETRANGE("Dimension Code", DimCode);
                        //IF NOT DocDimHdrActPosted.FINDFIRST THEN
                        if not DocDimHdrActPosted.get(irh."Dimension Set ID", DimCode) then
                            DocDimHdrActPosted."Dimension Value Code" := '';
                        IF DocDimHdrActPosted."Dimension Value Code" <> DocDimHdr."Dimension Value Code" THEN
                            IsError := TRUE;
                    END
                    ELSE BEGIN
                        //DocDimHdrActUnposted.SETRANGE("Line No.", 0);
                        //DocDimHdrActUnposted.SETRANGE("Dimension Code", DimCode);
                        //IF NOT DocDimHdrActUnposted.FINDFIRST THEN
                        if not DocDimHdrActUnposted.get(idh."Dimension Set ID", DimCode) then
                            DocDimHdrActUnposted."Dimension Value Code" := '';
                        IF DocDimHdrActUnposted."Dimension Value Code" <> DocDimHdr."Dimension Value Code" THEN
                            IsError := TRUE;
                    END;

                    IF IsError THEN
                        ERROR(locLabel002,
                          Dimension.Name, RcptActNo, "No.");
                END;
            UNTIL
              DocLine.NEXT = 0;
        // SWC816 AK 120516 <<
    end;
}
