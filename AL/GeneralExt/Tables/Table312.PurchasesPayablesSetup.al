tableextension 80312 "Purchases & Payab. Setup (Ext)" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50000; "Base Vendor No."; code[20])
        {
            Caption = 'Base Vendor No.';
            Description = 'NC 51373 AB';
            TableRelation = Vendor."No." where("Vendor Type" = CONST(Vendor));
        }
        field(50001; "Default Estimator"; code[50])
        {
            Caption = 'Default Estimator';
            Description = 'NC 51373 AB';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50003; "Cost Place Dimension"; code[20])
        {
            Caption = 'Cost Place Dimension';
            Description = 'NC 51373 AB';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                CheckCostDimension();
            end;
        }
        field(50004; "Base Resp. Employee No."; code[20])
        {
            Caption = 'Base Resp. Employee No.';
            Description = 'NC 51373 AB';
            TableRelation = Vendor."No." where("Vendor Type" = CONST("Resp. Employee"));
        }
        field(50005; "Zero VAT Prod. Posting Group"; code[20])
        {
            Caption = 'Zero VAT Prod. Posting Group';
            Description = 'NC 51373 AB';
            TableRelation = "VAT Product Posting Group";
        }
        field(50006; "Default Payment Assignment"; Text[15])
        {
            Caption = 'Default Payment Assignment';
            Description = 'NC 51378 AB';
            InitValue = '1';
        }
        field(50007; "Cost Code Dimension"; code[20])
        {
            Caption = 'Cost Code Dimension';
            Description = 'NC 51373 AB';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                CheckCostDimension();
            end;
        }
        field(50008; "Prices Incl. VAT in Req. Doc."; Boolean)
        {
            Description = 'NC 51374 AB';
            Caption = 'Prices Including VAT in Request Docs.';
        }
        field(50010; "Master Approver (Development)"; code[50])
        {
            Description = 'NC 51374 AB';
            Caption = 'Master Approver (Development)';
            TableRelation = "User Setup";
        }
        field(50011; "Master Approver (Production)"; code[50])
        {
            Description = 'NC 51374 AB';
            Caption = 'Master Approver (Production)';
            TableRelation = "User Setup";
        }
        field(50012; "Master Approver (Department)"; code[50])
        {
            Description = 'NC 51374 AB';
            Caption = 'Master Approver (Department)';
            TableRelation = "User Setup";
        }
        field(50013; "Skip Check CF in Doc. Lines"; Boolean)
        {
            Description = 'NC 51380 AB';
            Caption = 'Skip Check Cash Flow in Doc. Lines';
        }
        field(50020; "Frame Agreement Group"; Code[20])
        {
            Caption = 'Frame Agreement Group';
            Description = 'NC 51373 AB';
            TableRelation = "Agreement Group".Code WHERE(Type = CONST(Purchases));
        }
        field(50030; "Vendor Agreement Template Code"; Code[250])
        {
            Caption = 'Vendor Agreement Template Code';
            TableRelation = "Excel Template";
        }
        field(50031; "Check Vend. Agr. Template Code"; Code[250])
        {
            Caption = 'Check Vend. Agr. Template Code';
            TableRelation = "Excel Template";
        }
        field(50032; "Aged Acc. Payable Tmplt Code"; Code[250])
        {
            Caption = 'Aged Accounts Payable Template';
            TableRelation = "Excel Template";
        }
        field(70000; "Payment Calendar Tmpl"; Code[10])
        {
            TableRelation = "Gen. Journal Template".Name;
            Caption = 'Payment Calendar Template';
            Description = 'NC 51378 AB';

            trigger OnValidate()
            begin
                if Rec."Payment Calendar Tmpl" <> xRec."Payment Calendar Tmpl" then
                    "Payment Calendar Batch" := '';
            end;
        }
        field(70001; "Payment Calendar Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Calendar Tmpl"));
            Caption = 'Payment Calendar Batch';
            Description = 'NC 51378 AB';
        }
        field(70002; "Payment Delay Period"; DateFormula)
        {
            Description = 'NC 51373 AB';
            Caption = 'Payment Delay Period';
        }
        field(75007; "Payment Request Nos."; Code[10])
        {
            TableRelation = "No. Series";
            Caption = 'Payment Request Nos.';
            Description = 'NC 51378 AB';

        }
        field(75015; "Act Order Nos."; Code[10])
        {
            TableRelation = "No. Series";
            Caption = 'Act Order Nos.';
            Description = 'NC 51378 AB';
        }
    }

    local procedure CheckCostDimension()
    var
        LocText001: Label 'Same values are selected for %1 and %2.';
    begin
        IF ("Cost Place Dimension" <> '') and ("Cost Code Dimension" <> '') and ("Cost Code Dimension" = "Cost Place Dimension") then
            Error(LocText001, FieldCaption("Cost Code Dimension"), FieldCaption("Cost Place Dimension"));
    end;
}