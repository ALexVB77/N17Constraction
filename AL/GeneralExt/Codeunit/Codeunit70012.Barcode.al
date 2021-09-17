codeunit 70012 "Barcode"
{
    trigger OnRun()
    begin
    end;

    procedure Ean13(pBarcode: Text[13]) result: Text[30]
    var
        FirstFlag, Left, Right, pre, LeftCode, RightCode, First : Text;
        i: Integer;
        LocText001: label 'EAN %1 must be 13 characters long.';
    begin

        IF (pBarcode = '') THEN
            EXIT;

        IF STRLEN(pBarcode) < 13 THEN
            pBarcode := COPYSTR('0000000000000', 1, 13 - STRLEN(pBarcode)) + pBarcode;

        IF (STRLEN(pBarcode) <> 13) THEN
            ERROR(LocText001, pBarcode);

        CLEAR(result);
        FirstFlag := COPYSTR(pBarcode, 1, 1);
        Left := COPYSTR(pBarcode, 2, 6);
        Right := COPYSTR(pBarcode, 8, 6);
        LeftCode := '';
        RightCode := '';

        FOR i := 1 TO STRLEN(Right) DO BEGIN
            RightCode := RightCode + ToLowerChar(COPYSTR(Right, i, 1));
        END;

        CASE FirstFlag OF
            '0':
                BEGIN
                    First := '#!';
                    pre := 'AAAAAA';
                END;
            '1':
                BEGIN
                    First := '$!';
                    pre := 'AABABB';
                END;
            '2':
                BEGIN
                    First := '%!';
                    pre := 'AABBAB';
                END;
            '3':
                BEGIN
                    First := '&!';
                    pre := 'AABBBA';
                END;
            '4':
                BEGIN
                    First := '''!';
                    pre := 'ABAABB';
                END;
            '5':
                BEGIN
                    First := '(!';
                    pre := 'ABBAAB';
                END;
            '6':
                BEGIN
                    First := ')!';
                    pre := 'ABBBAA';
                END;
            '7':
                BEGIN
                    First := '*!';
                    pre := 'ABABAB';
                END;
            '8':
                BEGIN
                    First := '+!';
                    pre := 'ABABBA';
                END;
            '9':
                BEGIN
                    First := ',!';
                    pre := 'ABBABA';
                END;
        END;

        FOR i := 1 TO STRLEN(Left) DO BEGIN
            IF pre[i] = 'A' THEN
                LeftCode := LeftCode + COPYSTR(Left, i, 1)
            ELSE
                LeftCode := LeftCode + ToUpperChar(COPYSTR(Left, i, 1));
        END;

        result := First + LeftCode + '-' + RightCode + '!';

    end;

    local procedure ToLowerChar(d: Text[30]) res: Text[30]
    var
        CharSet: text;
        p: Integer;
    begin
        CharSet := 'abcdefghij';
        EVALUATE(p, d);
        res := COPYSTR(CharSet, p + 1, 1);
    end;

    local procedure ToUpperChar(d: Text[30]) res: Text[30]
    var
        CharSet: text;
        p: Integer;
    begin
        CharSet := 'ABCDEFGHIJ';
        EVALUATE(p, d);
        res := COPYSTR(CharSet, p + 1, 1);
    end;

    procedure CreateBarcode(pBarcodePart: Text[12]) Result: Text[13]
    var
        CheckStr: code[22];
        Chk: Integer;
        Char: text[1];
    begin
        IF STRLEN(pBarcodePart) < 12 THEN
            pBarcodePart := COPYSTR('2000000000000', 1, 12 - STRLEN(pBarcodePart)) + pBarcodePart;
        CheckStr := '131313131313';
        Chk := 1 + STRCHECKSUM(pBarcodePart, CheckStr);
        Char := SELECTSTR(Chk, '0,1,2,3,4,5,6,7,8,9');
        Result := pBarcodePart + Char;
        EXIT(Result);
    end;
}