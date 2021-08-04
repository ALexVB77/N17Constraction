page 70228 "CRM Company"
{
    SourceTable = "CRM Company";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'CRM Copmany';


    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("Project Guid"; Rec."Project Guid")
                {
                    ApplicationArea = All;

                }

                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;

                }

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;

                }



            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Test)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    d1: Dictionary of [Text, Dictionary of [Text, Text]];
                    d2: Dictionary of [Text, Text];

                begin
                    d2.Add('key', 'value');
                    d1.Add('table', d2);
                    Proc1(d1);
                    Proc2(d1);
                end;
            }

            action(Test2)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    pf: Record "CRM Prefetched Object";
                begin
                    Message('Underconstruction');
                end;
            }
        }
    }

    [TryFunction]
    local procedure Proc1(var dict1: Dictionary of [Text, Dictionary of [Text, Text]])
    var
        dict2: Dictionary of [Text, Text];
    begin
        dict1.Get('table', dict2);
        dict2.Add('key1', 'value2');
    end;

    local procedure Proc2(var dict1: Dictionary of [Text, Dictionary of [Text, Text]])
    var
        dict3: Dictionary of [Text, Text];
        Str: Text;
    begin
        dict1.Get('table', dict3);
        dict3.Get('key1', str);
        Message('value is %1', Str);
    end;



}
