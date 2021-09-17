pageextension 70909 "Bank Account Card BS" extends "Bank Account Card"
{
    layout
    {
        addafter(Transfer)
        {
            group(ClientBank)
            {
                Caption = 'Client Bank';
                field("Use Client-Bank"; Rec."Use Client-Bank")
                {
                    ApplicationArea = All;
                }

                field("Check Description for Import"; Rec."Check Description for Import")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    /*
        actions
        {
            addlast(navigation)
            {
                action(SetISM)
                {
                    Caption = 'set ism with error';
                    trigger OnAction()
                    var
                        ism: Codeunit "Isolated Storage Management BS";

                    begin
                        ism.init();
                        ism.setString('with_err', 'with error');
                        error('error set!!!');
                    end;
                }
                action(SetISM2)
                {
                    Caption = 'set ism without error';
                    trigger OnAction()
                    var
                        ism: Codeunit "Isolated Storage Management BS";
                    begin
                        ism.init();
                        ism.setString('without_err', 'without error');
                    end;
                }
                action(GetISM)
                {
                    Caption = 'get ism';
                    trigger OnAction()
                    var
                        ism: Codeunit "Isolated Storage Management BS";
                        val: Text;
                        str: text;

                    begin
                        ism.getString('with_err', val, false);
                        str := strsubstno('With error: ~%1~\', val);
                        ism.getString('without_err', val, false);
                        str += strsubstno('Without error: ~%1~', val);
                        message(str);
                    end;
                }

            }

        }
    */
}

