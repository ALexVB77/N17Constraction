page 70058 "Cust. E-Mail Notify Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Cust. E-Mail Notify Log";
    Editable = false;
    Caption = 'Cust. E-Mail Notify Log';

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("Date Time"; Rec."Date Time")
                {
                    ApplicationArea = All;

                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;

                }

                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;

                }

                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;

                }

                field(Body; Rec.Body)
                {
                    ApplicationArea = All;
                    /*
                    trigger OnAssistEdit()
                    var
                        FileName: text[250];
                    begin
                        CALCFIELDS(Body);
                        IF Body.HASVALUE THEN
                        IF CONFIRM('Открыть Письмо?') THEN BEGIN
                          FileName := ENVIRON('TEMP') + 'E-Mail.docx';
                          IF EXISTS(FileName) THEN
                            ERASE(FileName);
                          Body.EXPORT(FileName, FALSE);
                          HYPERLINK(FileName);
                        END;
                    end;
                    */

                }


            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(ExportMailBody)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'Export Mail Body';

                trigger OnAction();
                begin
                    Rec.ExportMailBody();
                end;
            }
        }
    }



}
