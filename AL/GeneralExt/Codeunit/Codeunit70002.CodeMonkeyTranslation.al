codeunit 70002 "Code Monkey Translation"
{
    var
        ErrText001: Label 'Unknown text constant - "%1".';

    procedure ConstOther(ConstantNameP: Text) Result: Text
    begin
        case ConstantNameP of
            'CC':
                Result := 'CC';
            else
                Error(ErrText001, ConstantNameP);
        end;
    end;

    procedure ConstCompany(ConstantNameP: Text) Result: Text
    begin
        case ConstantNameP of
            'NCC Real Estate':
                Result := 'NCC Real Estate';
            'NCC Construction':
                Result := 'NCC Construction';
            'NCC Village':
                Result := 'NCC Village';
            else
                Result := ConstantNameP;
        end;
    end;
}