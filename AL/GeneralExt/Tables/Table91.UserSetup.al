tableextension 80091 "User Setup (Ext)" extends "User Setup"
{
    fields
    {
        field(50000; "Change Agreem. Posting Group"; Boolean)
        {
            Caption = 'Allow changing agr. posting group';
        }
        field(70010; "Vend. Agr. Creator Notif."; Boolean)
        {
            Description = 'NC 51432 PA';
            Caption = 'Vend. Agr. Creator Notif.';
        }
        field(70011; "Vend. Agr. Controller Notif."; Boolean)
        {
            Description = 'NC 51432 PA';
            Caption = 'Vend. Agr. Controller Notif.';
        }
        field(70017; "Allow Manual Editing"; Boolean)
        {
            Description = 'NC 51228 OA';
            Caption = 'Allow Manual Editing';
        }
        field(70023; "Allow Edit DenDoc Dimension"; Boolean)
        {
            Description = 'NC 51676';
            Caption = 'Allow Edit DenDoc Dimension';
        }
        field(71000; "CF Allow Long Entries Edit"; Boolean)
        {
            Description = 'NC 51381';
            Caption = 'CF Allow Long Term Entries Edit';
        }
        field(71010; "CF Allow Short Entries Edit"; Boolean)
        {
            Description = 'NC 51381';
            Caption = 'CF Allow Short Term Entries Edit';
        }
        field(71015; "Master CF"; Boolean)
        {
            Description = 'NC 51383';
            Caption = 'Master CF';
        }
        field(71020; "Last Project Code"; Code[20])
        {
            Description = 'NC 51382';
            Caption = 'Last Project Code';
        }
    }

    var
        UserSetup: Record "User Setup";
        UserSubstLoop: Record "User Setup" temporary;
        ConfText001: Label 'User %1 has status %2 now. Do you want to change to %3?';


    procedure GetUserSubstitute(UserCode: Code[50]; StepNo: integer) Result: Code[50]
    var
        UserSetup: Record "User Setup";
        LoopErrText: Label 'Loop detected while looking for substitute: user %1, step %2.';
        ShowError: Boolean;
    begin
        if StepNo <= 0 then begin
            ShowError := StepNo < 0;
            UserSubstLoop.Reset;
            UserSubstLoop.DeleteAll();
            StepNo := 0;
        end else
            StepNo += 1;

        if UserCode = '' then
            exit('');
        if not UserSetup.GET(UserCode) then
            exit('');
        if UserSetup.Absents then begin
            if UserSetup.Substitute = '' then
                exit('');
            if UserSubstLoop.Get(UserSetup.Substitute) then begin
                if ShowError then
                    Error(LoopErrText, UserSetup.Substitute, StepNo)
                else
                    exit('');
            end;
            UserSubstLoop.Init;
            UserSubstLoop."User ID" := UserSetup.Substitute;
            UserSubstLoop.Insert;
            exit(GetUserSubstitute(UserSetup.Substitute, StepNo));
        end else
            exit(UserSetup."User ID");
    end;

}
