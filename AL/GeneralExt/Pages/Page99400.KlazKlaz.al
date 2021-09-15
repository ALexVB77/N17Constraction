page 99400 "Klaz Klaz"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Test rec";
    Caption = 'Klaz Klaz', Locked = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }

            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(ExportJsonScheme)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'ExportJsonScheme', Locked = true;

                trigger OnAction();
                var
                    cu: codeunit "CRM Object Xml to Json";
                begin

                    cu.ExportScheme();
                end;
            }

            action(EnumEval)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'EnumEval', Locked = true;

                trigger OnAction();
                var
                    FieldValue: Enum "Investment Object Type";
                    NewTextValue: Text;
                begin
                    FieldValue := FieldValue::" ";
                    NewTextValue := 'Office';
                    Evaluate(FieldValue, NewTextValue);
                    Message('Value is <%1>', FieldValue);
                end;
            }

            action(TestVariant)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'EnumEval', Locked = true;

                trigger OnAction();
                var
                    IntVal: Integer;
                begin
                    IntVal := 0;
                    GetValue(IntVal);
                    Message('Value is <%1>', IntVal);
                end;
            }

        }
    }

    local procedure GetValue(OutVlaue: Variant)
    var
        Val: Integer;
    begin
        Val := 99812;
        OutVlaue := Val;

    end;

}
