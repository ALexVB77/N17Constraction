tableextension 85109 "Purchase Header Archive (Ext)" extends "Purchase Header Archive"
{
    fields
    {
        field(50001; "Payment Assignment"; Text[15])
        {
            Description = 'NC 51378 AB';
            Caption = 'Payment Assignment';
        }
        field(50002; "Inv.-Fact. is Received"; Boolean)
        {
            Caption = 'Inv.-Fact. is Received';
            Description = 'NC 50280 OA';
        }
        field(50003; "Act is Received"; Boolean)
        {
            Caption = 'Act is Received';
            Description = 'NC 50280 OA';
        }
        field(50010; "Linked Purchase Order Act No."; Code[20])
        {
            Description = 'NC 51378 AB';
            Caption = 'Linked Purchase Order Act No.';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(50011; "Archiving Type"; Option)
        {
            Description = 'NC 51378 AB';
            Caption = 'Archiving Type';
            OptionCaption = ' ,Problem Act,Payment Invoice';
            OptionMembers = " ","Problem Act","Payment Invoice";
        }
        field(50012; "Sent to pre. Approval"; Boolean)
        {
            Description = 'NC 51374 AB';
            Caption = 'Sent to pre. approval';
        }
        field(50013; "Receptionist"; code[50])
        {
            Caption = 'Receptionist';
            Description = 'NC 51380 AB';
        }
        field(50022; "Spec. Bank Account No."; Code[20])
        {
            TableRelation = "Bank Account";
            Caption = 'Spec. Bank Account No.';
            Description = 'NC 51379 AB';
        }
        field(60088; "Original Company"; Code[2])
        {
            Description = 'NC 51432 AP';
            Caption = 'Original Company';
        }
        field(70002; "Process User"; Code[50])
        {
            TableRelation = "User Setup";
            Description = 'NC 51373 AB';
            Caption = 'Process User';
        }
        field(70003; "Date Status App"; Date)
        {
            Description = 'NC 51373 AB';
            Caption = 'Date Status Approval';
        }
        field(70005; "Exists Attachment"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Document Attachment" WHERE("Table ID" = CONST(5109), "Document Type" = FIELD("Document Type"), "No." = FIELD("No.")));
            Description = 'NC 51373 AB';
            Caption = 'Exists Attachment';
        }
        field(70007; "Payments Amount"; Decimal)
        {
            // Переделано из Normal на FlowField
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount
                            where("Vendor No." = field("Buy-from Vendor No."),
                                    "Initial Document Type" = const(Payment),
                                    "IW Document No." = field("No."),
                                    "Entry Type" = const("Initial Entry")));
            Caption = 'Payments Amount';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70008; "Invoice VAT Amount"; Decimal)
        {
            Description = 'NC 51373 AB';
            Caption = 'VAT Amount';
        }
        field(70009; "Invoice Amount Incl. VAT"; Decimal)
        {
            Description = 'NC 51373 AB';
            Caption = 'Invoice Amount Incl. VAT';
        }
        field(70010; "Payment Type"; Option)
        {
            Description = 'NC 51378 AB';
            Caption = 'Payment Type';
            OptionCaption = 'Prepay,Postpay';
            OptionMembers = "pre-pay","post-payment";
        }
        field(70011; "Payment Doc Type"; Option)
        {
            Description = 'NC 51373 AB';
            Caption = 'Payment Doc Type';
            OptionCaption = 'Invoice,Payment Request';
            OptionMembers = Invoice,"Payment Request";
        }
        field(70012; "Payment Details"; Text[230])
        {
            Description = 'NC 51373 AB';
            Caption = 'Payment Details';
        }
        field(70013; "Vendor Bank Account"; Code[20])
        {
            Description = 'NC 51373 AB';
            Caption = 'Vendor Bank Account';
            TableRelation = "Bank Directory".BIC;
            ValidateTableRelation = false;
        }
        field(70014; "Vendor Bank Account No."; Text[30])
        {
            Description = 'NC 51373 AB';
            Caption = 'Vendor Bank Account #';
            TableRelation = "Vendor Bank Account".Code WHERE("Vendor No." = field("Pay-to Vendor No."));
            ValidateTableRelation = false;
        }
        field(70015; Controller; Code[50])
        {
            Caption = 'Controller';
            Description = 'NC 51373 AB';
            TableRelation = "User Setup"."User ID" WHERE("Status App Act" = CONST(1));
            ValidateTableRelation = false;
        }
        field(70017; "External Agreement No. (Calc)"; Text[30])
        {
            CalcFormula = Lookup("Vendor Agreement"."External Agreement No." WHERE("Vendor No." = FIELD("Buy-from Vendor No."), "No." = FIELD("Agreement No.")));
            Caption = 'External Agreement No.';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
        }
        field(70018; "Paid Date Fact"; Date)
        {
            // Переделано из Normal на FlowField
            CalcFormula = max("Detailed Vendor Ledg. Entry"."Posting Date"
                            where("Vendor No." = field("Buy-from Vendor No."),
                                    "Initial Document Type" = const(Payment),
                                    "IW Document No." = field("No."),
                                    "Entry Type" = const("Initial Entry")));
            Caption = 'Paid Date Fact';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70019; "Problem Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Problem Document';
        }
        field(70020; "Problem Type"; enum "Purchase Problem Type")
        {
            Caption = 'Problem Type';
            Description = 'NC 51373 AB';
        }
        field(70021; "OKATO Code"; Text[30])
        {
            TableRelation = OKATO;
            Description = 'NC 51373 AB';
            Caption = 'OKATO Code';
        }
        field(70022; "KBK Code"; Text[30])
        {
            TableRelation = KBK;
            Description = 'NC 51373 AB';
            Caption = 'KBK Code';
        }
        field(70024; "Pre-Approver"; Code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Pre-Approver';
            TableRelation = "User Setup";
        }
        field(70027; "IW Planned Repayment Date"; Date)
        {
            Description = 'NC 51378 AB';
            Caption = 'IW Planned Repayment Date';
        }
        field(70034; "IW Documents"; Boolean)
        {
            Caption = 'IW Documents';
            Description = 'NC 50085 PA';
        }
        field(70038; "Pre-booking Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Pre-booking Document';
        }
        field(70039; "Pre-booking Accept"; Boolean)
        {
            Caption = 'Pre-booking Accept';
            Description = 'NC 51373 AB';
        }
        field(70045; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
            Description = 'NC 51373 AB';
        }
        field(70047; "Payment to Person"; Boolean)
        {
            Caption = 'Payment to Person';
            Description = 'NC 51378 AB';
        }
        field(90003; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            Description = 'NC 51373 AB';
            Caption = 'Approval Status';
        }
        field(90004; Estimator; Code[50])
        {
            Caption = 'Estimator';
            Description = 'NC 51373 AB';
            TableRelation = "User Setup"."User ID" WHERE("Status App Act" = CONST(Estimator));
        }
        field(90006; "Act Invoice No."; Code[20])
        {
            Caption = 'Act Invoice No.';
            Description = 'NC 51373 AB';
        }
        field(90007; "Act Invoice Posted"; Boolean)
        {
            Caption = 'Act Invoice Posted';
            Description = 'NC 51373 AB';
        }
        field(90009; "Receive Account"; Boolean)
        {
            Caption = 'Receive Account';
            Description = 'NC 51373 AB';
        }
        field(90019; "Location Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Location Document';
        }
        field(90020; Storekeeper; Code[50])
        {
            TableRelation = "User Setup";
            Description = 'NC 51373 AB';
            Caption = 'Storekeeper';
        }
    }

    procedure GetAddTypeCommentArchText(AddType: enum "Purchase Comment Add. Type"): text
    var
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        PurchCommentLineArch.SetRange("Document Type", "Document Type".AsInteger());
        PurchCommentLineArch.SetRange("No.", "No.");
        PurchCommentLineArch.SetRange("Document Line No.", 0);
        PurchCommentLineArch.SetRange("Add. Line Type", AddType);
        if PurchCommentLineArch.FindLast() then
            exit(PurchCommentLineArch.Comment + PurchCommentLineArch."Comment 2");
    end;

    procedure SetAddTypeCommentArchText(AddType: enum "Purchase Comment Add. Type"; NewComment: text)
    var
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        PurchCommentLineArch.SetRange("Document Type", "Document Type".AsInteger());
        PurchCommentLineArch.SetRange("No.", "No.");
        PurchCommentLineArch.SetRange("Document Line No.", 0);
        PurchCommentLineArch.SetRange("Add. Line Type", AddType);
        if not PurchCommentLineArch.FindLast() then begin
            PurchCommentLineArch.Init();
            PurchCommentLineArch."Document Type" := "Document Type".AsInteger();
            PurchCommentLineArch."No." := "No.";
            PurchCommentLineArch."Document Line No." := 0;
            PurchCommentLineArch."Line No." := 10000;
            PurchCommentLineArch.Date := Today;
            PurchCommentLineArch."Add. Line Type" := AddType;
            PurchCommentLineArch.Insert(true);
        end;
        PurchCommentLineArch.Comment := CopyStr(NewComment, 1, MaxStrLen(PurchCommentLineArch.Comment));
        PurchCommentLineArch."Comment 2" :=
          CopyStr(NewComment, MaxStrLen(PurchCommentLineArch.Comment) + 1, MaxStrLen(PurchCommentLineArch."Comment 2"));
        PurchCommentLineArch.Modify(true);
    end;

}