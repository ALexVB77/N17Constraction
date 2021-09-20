page 70038 "Proj. Cost Control Entry Buf."
{
    Editable = false;
    InsertAllowed = false;
    SourceTable = "Proj. Cost Control Entry Buf.";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Proj. Cost Control Entry Buf.';

    layout
    {
        area(content)
        {
            group(Amount)
            {
                field(GetAmount1; GetAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
            }
            repeater(Repeater1237120003)
            {
                field("Project Code"; "Project Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Project Turn Code"; "Project Turn Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Analysis Type"; "Analysis Type")
                {
                    Visible = false;
                    ApplicationArea = All;

                }

                field(Reversed; Reversed)
                {
                    Visible = false;
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field(Date; Date)
                {
                    ApplicationArea = All;

                }

                field("Original Date"; "Original Date")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Doc No."; "Doc No.")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchInvHeader: record "Purch. Inv. Header";
                    begin
                        IF "Doc Type" = 0 THEN BEGIN
                            PurchaseHeader.SETRANGE("No.", "Doc No.");
                            IF PurchaseHeader.FINDFIRST THEN
                                PAGE.RUN(70184, PurchaseHeader)
                            ELSE BEGIN
                                PurchInvHeader.SETRANGE("No.", "Doc No.");
                                IF PurchInvHeader.FINDFIRST THEN
                                    PAGE.RUN(138, PurchInvHeader);


                            END;
                        END;

                        IF "Doc Type" = 1 THEN BEGIN
                            PurchInvHeader.SETRANGE("No.", "Doc No.");
                            IF PurchInvHeader.FINDFIRST THEN
                                PAGE.RUN(138, PurchInvHeader);


                        END;
                    end;


                }

                field(Code; Code)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("IFRS Account No."; "IFRS Account No.")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Description; Description)
                {
                    ApplicationArea = All;

                }

                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;

                }

                field(WithoutVAT; "Without VAT")
                {
                    DecimalPlaces = 0 : 0;
                    ApplicationArea = All;
                    Caption = 'Without VAT';
                    trigger OnValidate()
                    begin

                        FieldOnAfterValidate; //navnav;
                    end;


                }

                field("Cost Type"; "Cost Type")
                {
                    ApplicationArea = All;

                }

                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Contragent No."; "Contragent No.")
                {
                    ApplicationArea = All;

                }

                field("Contragent Name"; "Contragent Name")
                {
                    ApplicationArea = All;

                }

                field("Agrrement No."; "Agreement No.")
                {
                    ApplicationArea = All;

                }

                field("External Agreement No."; "External Agreement No.")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Changed; Changed)
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }



            }
        }
    }


    actions
    {
        area(navigation)
        {
        }
    }


    trigger OnAfterGetCurrRecord()
    var
        CLE: record "Change Log Entry";
    begin
    end;

    trigger OnOpenPage()
    begin

        FieldOnFormat; //navnav;
    end;



    var
        vPrj: code[20];
        vType: integer;
        vVer: code[20];
        vLine: integer;
        grPrjStrLine: record "Projects Structure Lines";
        // frmAdjustedBudget: page "Adjusted Budget";
        grDevelopmentSetup: record "Development Setup";
        // gcduERPC: codeunit "ERPC Funtions";
        // ProjectVersion: record "Project Version";
        // DataType: 'all,act,comm,res,ytb';
        PurchaseHeader: record "Purchase Header";
        ShowReversed: boolean;
        Dim1: code[20];
        TEXT001: Label 'Operations cannot be changed!';
        TEXT002: Label 'You cannot delete operations!';
        grPCCE: record "Projects Cost Control Entry" temporary;
        US: record "User Setup";


    procedure GetAmount() Ret: Decimal
    var
        ProjectsCostControlEntry: record "Proj. Cost Control Entry Buf.";
    begin
        //ProjectsCostControlEntry.COPY(Rec);
        ProjectsCostControlEntry.SETCURRENTKEY("Project Code", "Analysis Type", "Line No.");
        ProjectsCostControlEntry.CALCSUMS("Without VAT");
        Ret := ProjectsCostControlEntry."Without VAT";

        //IF ProjectsCostControlEntry.FINDSET THEN
        //  REPEAT
        //    Ret+= ProjectsCostControlEntry."Without VAT";
        //  UNTIL ProjectsCostControlEntry.NEXT=0;
    end;

    local procedure FieldOnFormat()
    begin
        //IF (GetAgreement("Doc No.","Without VAT")<>"Agrrement No.") AND (GetAgreement("Doc No.","Without VAT")<>'') THEN
        //CurrForm.Description.UPDATEFORECOLOR:=255;
    end;

    local procedure FieldOnAfterValidate()
    begin
        IF "Entry No." <> 0 THEN BEGIN
            IF xRec."Without VAT" <> 0 THEN BEGIN
                MESSAGE(TEXT001);
                "Without VAT" := xRec."Without VAT";
            END;
        END;
    end;


}

