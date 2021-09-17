codeunit 70100 "Isolated Storage Management BS"

/*
  Ахтунг: 
    Так как это single instance, то error'ы в процессе работы не сбрасывают установленные здесь переменные.
    Поэтому перед заходом в транзакцию желательно вызывать функцию init, находящуюся в этом cu.
*/

{
    SingleInstance = true;

    procedure setString(_key: Code[50]; val: Text): Text
    begin
        exit(setValue(_key, val));
    end;

    procedure getString(_key: code[50]; var val: text; deleteAfterRead: Boolean): Boolean
    var
        bRes: Boolean;
    begin
        bRes := getValue(_key, val);
        if (bres and deleteAfterRead) then delValue(_key);
        exit(bres);

    end;

    local procedure format(_key: Code[50]): Text
    begin
        exit(strsubstno('%1:%2', _key, SessionId()));
    end;

    procedure delValue(_key: code[50])
    begin
        storage.Remove(format(_key));
    end;

    procedure clearAll()
    begin
        clear(storage);
    end;

    local procedure setValue(_key: Code[50]; value: Text[250]): Text
    var
        sRes: Text;
    begin
        storage.Set(format(_key), value, sres);
        exit(sRes);
    end;

    local procedure getValue(_key: Code[50]; var val: Text[250]): Boolean
    var
        bRes: Boolean;
        ErrorInISM: Label 'Error caught in isolated storage: %1';
    begin
        if (GetLastErrorText <> '') then begin
            clearAll();
            //if (not hideError) then begin
            //    Error(ErrorInISM, GetLastErrorText);
            //end;
        end;

        val := '';
        if (storage.ContainsKey(format(_key))) then begin
            val := storage.Get(format(_key));
            bRes := true;
        end;
        exit(bRes);
    end;

    //procedure setHideError(p: boolean)
    //begin
    //    hideError := p;
    //end;

    procedure init()
    begin
        ClearLastError();
        clearAll();
    end;

    var
        storage: Dictionary of [Text, Text];
    //hideError: Boolean;
}


