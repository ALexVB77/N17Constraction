page 70032 "Projects Budget Entry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Projects Budget Entry";
    Caption = 'Project Budget Entry';
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Rep1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Close; Rec.Close)
                {
                    ApplicationArea = All;
                }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(Dim2CodeDesc; Dim2CodeDesc)
                {
                    Caption = 'CC Description';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment Description"; Rec."Payment Description")
                {
                    ApplicationArea = All;
                }
                field("Without VAT (LCY)"; Rec."Without VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = All;
                }
                field("Contragent Name"; Rec."Contragent Name")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("External Agreement No."; Rec."External Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Doc. No."; Rec."Payment Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Create User"; Rec."Create User")
                {
                    ApplicationArea = All;
                }
                field("Parent Entry"; Rec."Parent Entry")
                {
                    ApplicationArea = All;
                }
                field("Close Date"; Rec."Close Date")
                {
                    ApplicationArea = All;
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = All;
                }
            }
            group(GrFoot)
            {
                field(DateF; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 CodeF"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 CodeF"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(Dim2CodeDescF; Dim2CodeDesc)
                {
                    Caption = 'CC Description';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment DescriptionF"; Rec."Payment Description")
                {
                    ApplicationArea = All;
                }
                field("Without VAT (LCY)F"; Rec."Without VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Contragent No.F"; Rec."Contragent No.")
                {
                    ApplicationArea = All;
                }
                field("Contragent NameF"; Rec."Contragent Name")
                {
                    ApplicationArea = All;
                }
                field("Agreement No.F"; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("External Agreement No.F"; GetExternalNo())
                {
                    ApplicationArea = All;
                }
                field("Create DateF"; Rec."Create Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        Dim2CodeDesc: Text;

    local procedure GetExternalNo() Ret: Text
    var
        lrVendorAgreement: Record "Vendor Agreement";
        lrCustomerAgreement: Record "Customer Agreement";
    begin
        IF Rec."Contragent Type" = Rec."Contragent Type"::Vendor THEN BEGIN
            IF Rec."Agreement No." <> '' THEN BEGIN
                lrVendorAgreement.SETRANGE("No.", Rec."Agreement No.");
                IF lrVendorAgreement.FINDFIRST THEN BEGIN
                    Ret := lrVendorAgreement."External Agreement No.";
                END;
            END;
        END
        ELSE BEGIN
            IF Rec."Agreement No." <> '' THEN BEGIN
                lrCustomerAgreement.SETRANGE("No.", Rec."Agreement No.");
                IF lrCustomerAgreement.FINDFIRST THEN BEGIN
                    Ret := lrCustomerAgreement."External Agreement No.";
                END;
            END;
        END;

    end;
}