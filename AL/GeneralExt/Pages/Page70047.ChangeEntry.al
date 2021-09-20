page 70047 "Change Entry"
{
    Caption = 'Change Entry';
    PageType = Card;
    SourceTable = "Projects Cost Control Entry";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;

                }
                field("Original Date"; Rec."Original Date")
                {
                    ApplicationArea = All;
                }
                field("Doc No."; Rec."Doc No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.Validate("Agreement No.", '');
                    end;
                }
                field("Contragent Name"; Rec."Contragent Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("External Agreement No."; Rec."External Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Without VAT"; Rec."Without VAT")
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
            action(Apply)
            {
                Caption = 'Apply';
                Image = Apply;
                ApplicationArea = All;

                trigger OnAction()
                var
                    OldCT: Code[20];
                begin

                    grPCCE.SETRANGE("Project Code", Rec."Project Code");
                    grPCCE.SETRANGE("Analysis Type", Rec."Analysis Type");
                    grPCCE.SETRANGE("Entry No.", Rec."Entry No.");
                    IF grPCCE.FINDFIRST THEN BEGIN
                        // RecRef1.OPEN(271);
                        // RecRef2.OPEN(271);

                        grPCCEOld.SETRANGE("Project Code", Rec."Project Code");
                        grPCCEOld.SETRANGE("Analysis Type", Rec."Analysis Type");
                        grPCCEOld.SETRANGE("Entry No.", Rec."Entry No.");
                        IF grPCCEOld.FINDFIRST THEN BEGIN
                            grPCCEOld."Building Turn" := grPCCEOld."Project Turn Code";
                            grPCCEOld."Cost Code" := grPCCEOld.Code;
                        END;
                        // RecRef1.GETTABLE(grPCCEOld);
                        // //SWC 227 EN 060814 >>
                        // IF "Cost Type" <> xRec."Cost Type" THEN
                        //     OldCT := "Cost Type";
                        // //SWC 227 EN 060814 <<
                        // OldCT := grPCCE."Cost Type";


                        grPCCE.TRANSFERFIELDS(Rec);
                        // grPCCE."Cost Type" := OldCT;
                        grPCCE.MODIFY;
                        grPCCE.RENAME(Rec."Project Code", Rec."Analysis Type", Rec."Version Code", Rec."New Lines", Rec."Entry No.", Rec."Building Turn", Rec."Temp Line No.", Rec."Cost Type");


                        grPCCENew.SETRANGE("Project Code", Rec."Project Code");
                        grPCCENew.SETRANGE("Analysis Type", Rec."Analysis Type");
                        grPCCENew.SETRANGE("Entry No.", Rec."Entry No.");
                        IF grPCCENew.FINDFIRST THEN;


                        // RecRef2.GETTABLE(grPCCENew);

                        // cdu423.LogModification(RecRef2, RecRef1);


                    END;
                    CurrPage.CLOSE;
                end;
            }
        }
    }

    var
        grPCCE: Record "Projects Cost Control Entry";
        LineNo: Integer;
        // RecRef1: RecordRef;
        // RecRef2: RecordRef;
        grPCCEOld: Record "Projects Cost Control Entry";
        grPCCENew: Record "Projects Cost Control Entry";
}