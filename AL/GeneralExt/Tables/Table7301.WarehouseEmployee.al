tableextension 87301 "Warehouse Employee (Ext)" extends "Warehouse Employee"
{
    procedure GetDefaultLocation(pUserID: code[50]; ShowMessage: Boolean): Code[20]
    var
        WarehouseEmployee: record "Warehouse Employee";
        Text50002: Label 'There is no Storekeeper Warehouse setting for the current user. Please contact your administrator.';
    begin
        //NC 22512 > DP
        IF pUserID = '' THEN
            pUserID := USERID;
        WarehouseEmployee.SETRANGE("User ID", pUserID);
        WarehouseEmployee.SETRANGE(Default, TRUE);
        IF WarehouseEmployee.FINDFIRST THEN
            EXIT(WarehouseEmployee."Location Code")
        ELSE
            IF ShowMessage then
                ERROR(Text50002);
        //NC 22512 < DP
    end;
}