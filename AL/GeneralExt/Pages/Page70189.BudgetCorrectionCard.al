page 70189 "Budget Correction Card"
{
    SourceTable = "Budget Correction";
    PageType = Card;
    Caption = 'Budget Adjustment Card';


    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        StatusOnAfterValidate; //navnav;

                    end;


                }

                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Correction Batch"; Rec."Correction Batch")
                {
                    Editable = FieldsEditable;
                    ApplicationArea = All;
                    Caption = 'Save original entry sign';

                }

                // field("Virtual Agreement"; Rec."Virtual Agreement")
                // {
                //     ApplicationArea = All;

                // }   

                // field(Advances; Rec.Advances)
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;
                //     trigger OnValidate()
                //     begin
                //         AdvancesOnAfterValidate; //navnav;

                //     end;


                // }   

                // field("Agreement From Current Company"; Rec."Agreement From Current Company")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }   

                // field("Agreement Company Name"; Rec."Agreement Company Name")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Without VAT"; Rec."Without VAT")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }   

                // field(Allocation; Rec.Allocation)
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;
                //     trigger OnValidate()
                //     begin
                //         AllocationOnAfterValidate; //navnav;

                //     end;


                // }   

                // field("IFRS Costs"; Rec."IFRS Costs")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }   



            }
            group(Control12370022)
            {
                Caption = 'Data selection options';
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

                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }

                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }



            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        Rec.SETRANGE(Code);

        IF Rec.Status = Rec.Status::Active THEN
            SetEditable(FALSE)
        ELSE
            SetEditable(TRUE);

        // IF Advances THEN CurrPage.Allocation.ENABLED:=FALSE ELSE CurrPage.Allocation.ENABLED:=TRUE;
        // IF Allocation THEN CurrPage.Advances.ENABLED:=FALSE ELSE CurrPage.Advances.ENABLED:=TRUE;
    end;



    var
        FieldsEditable: Boolean;

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
        // CurrPage."Journal Template Name".EDITABLE:=b;
        // CurrPage."Journal Batch Name".EDITABLE:=b;
        // CurrPage."Source Code".EDITABLE:=b;
        // CurrPage."Company Name".EDITABLE:=b;
        // CurrPage."Correction Batch".EDITABLE:=b;
        // CurrPage."Virtual Agreement".EDITABLE:=b;
        // CurrPage.Advances.EDITABLE:=b;
        // CurrPage."Without VAT".EDITABLE:=b;
        // CurrPage.Allocation.EDITABLE:=b;
    end;

    local procedure StatusOnAfterValidate()
    begin
        CurrPage.UPDATE;

    end;
}