page 70188 "Budget Corrections"
{
    InsertAllowed = false;
    SourceTable = "Budget Correction";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Budget Adjustment';
    CardPageId = "Budget Correction Card";

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Dimension Totaling 1"; Rec."Dimension Totaling 1")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        EXIT(Rec.LookUpDimFilter(1, Text));
                    end;


                }

                field("Dimension Totaling 2"; Rec."Dimension Totaling 2")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        EXIT(Rec.LookUpDimFilter(2, Text));
                    end;


                }

                field("G/L Account Totaling"; Rec."G/L Account Totaling")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    var
                        GLAccList: page "G/L Account List";
                        LocGLAcc: record "G/L Account";
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        LocGLAcc.RESET;
                        IF Rec."Company Name" <> '' THEN
                            LocGLAcc.CHANGECOMPANY("Company Name")
                        ELSE
                            LocGLAcc.CHANGECOMPANY(COMPANYNAME);
                        IF LocGLAcc.FINDFIRST THEN;

                        //GLAccList.SetCompany("Company Name");

                        GLAccList.SETRECORD(LocGLAcc);
                        GLAccList.SETTABLEVIEW(LocGLAcc);
                        GLAccList.LOOKUPMODE(TRUE);
                        IF NOT (GLAccList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := GLAccList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;


                }

                field("G/L Account Totaling 1"; Rec."G/L Account Totaling 1")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    var
                        GLAccList: page "G/L Account List";
                        LocGLAcc: record "G/L Account";
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        LocGLAcc.RESET;
                        IF Rec."Company Name" <> '' THEN
                            LocGLAcc.CHANGECOMPANY("Company Name")
                        ELSE
                            LocGLAcc.CHANGECOMPANY(COMPANYNAME);
                        IF LocGLAcc.FINDFIRST THEN;

                        //GLAccList.SetCompany("Company Name");

                        GLAccList.SETRECORD(LocGLAcc);
                        GLAccList.SETTABLEVIEW(LocGLAcc);
                        GLAccList.LOOKUPMODE(TRUE);
                        IF NOT (GLAccList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := GLAccList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;


                }

                field("G/L Account Totaling 2"; Rec."G/L Account Totaling 2")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    var
                        GLAccList: page "G/L Account List";
                        LocGLAcc: record "G/L Account";
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        LocGLAcc.RESET;
                        IF Rec."Company Name" <> '' THEN
                            LocGLAcc.CHANGECOMPANY("Company Name")
                        ELSE
                            LocGLAcc.CHANGECOMPANY(COMPANYNAME);
                        IF LocGLAcc.FINDFIRST THEN;

                        //GLAccList.SetCompany("Company Name");

                        GLAccList.SETRECORD(LocGLAcc);
                        GLAccList.SETTABLEVIEW(LocGLAcc);
                        GLAccList.LOOKUPMODE(TRUE);
                        IF NOT (GLAccList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := GLAccList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;


                }

                field("G/L Account Totaling 3"; Rec."G/L Account Totaling 3")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    trigger OnLookup(var Text: text): boolean
                    var
                        GLAccList: page "G/L Account List";
                        LocGLAcc: record "G/L Account";
                    begin
                        IF Rec.Status = Rec.Status::Active THEN EXIT(FALSE);

                        LocGLAcc.RESET;
                        IF Rec."Company Name" <> '' THEN
                            LocGLAcc.CHANGECOMPANY("Company Name")
                        ELSE
                            LocGLAcc.CHANGECOMPANY(COMPANYNAME);
                        IF LocGLAcc.FINDFIRST THEN;

                        //GLAccList.SetCompany("Company Name");

                        GLAccList.SETRECORD(LocGLAcc);
                        GLAccList.SETTABLEVIEW(LocGLAcc);
                        GLAccList.LOOKUPMODE(TRUE);
                        IF NOT (GLAccList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := GLAccList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;


                }

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;

                }

                // field("Agreement Company Name"; Rec."Agreement Company Name")
                // {
                //     ApplicationArea = All;

                // }   

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        StatusOnAfterValidate; //navnav;

                    end;


                }

                // field("IFRS Costs"; Rec."IFRS Costs")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }   



            }
        }
    }



    trigger OnAfterGetCurrRecord()
    begin
        IF Rec.Status = Rec.Status::Active THEN
            SetEditable(FALSE)
        ELSE
            SetEditable(TRUE);
    end;


    var
        FieldsEditable: Boolean;


    procedure GetRec(var vRec: record "Budget Correction")
    begin
        vRec.COPY(Rec);
    end;

    procedure SetEditable(b: boolean)
    begin
        FieldsEditable := b;
        // CurrPage.Code.EDITABLE:=b;
        // CurrPage."Project Code".EDITABLE:=b;
        // CurrPage.Name.EDITABLE:=b;
        // CurrPage."Dimension Totaling 1".EDITABLE:=b;
        // CurrPage."Dimension Totaling 2".EDITABLE:=b;
        // CurrPage."G/L Account Totaling".EDITABLE:=b;
        // CurrPage."G/L Account Totaling 1".EDITABLE:=b;
        // CurrPage."G/L Account Totaling 2".EDITABLE:=b;
        // CurrPage."G/L Account Totaling 3".EDITABLE:=b;
        // //CurrForm."Priod Group Type".EDITABLE:=b;
        // //CurrForm.Description.EDITABLE:=b;
        // //CurrForm."Journal Template Name".EDITABLE:=b;
        // //CurrForm."Journal Batch Name".EDITABLE:=b;
        // //CurrForm."Source Code".EDITABLE:=b;
        // CurrPage."Company Name".EDITABLE:=b;
        // //CurrForm."Correction Batch".EDITABLE:=b;
    end;

    local procedure StatusOnAfterValidate()
    begin
        CurrPage.UPDATE;
    end;


}