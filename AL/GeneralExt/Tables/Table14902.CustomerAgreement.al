tableextension 94902 "Customer Agreement (Ext)" extends "Customer Agreement"
{
    fields
    {

        modify("Customer Posting Group")
        {
            trigger OnAfterValidate()
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                UserSetup: Record "User Setup";
                SalesSetup: Record "Sales & Receivables Setup";
                LabelPstGrChanging: Label 'You cannot change %1 till you set up %2 of %3';
            begin

                IF ("Customer Posting Group" <> xRec."Customer Posting Group") THEN BEGIN
                    CustLedgEntry.RESET;
                    CustLedgEntry.SETCURRENTKEY("Posting Date", "Customer No.", "Agreement No.");
                    CustLedgEntry.SETRANGE("Customer No.", "Customer No.");
                    CustLedgEntry.SETRANGE("Agreement No.", "No.");
                    IF NOT CustLedgEntry.ISEMPTY THEN BEGIN
                        SalesSetup.GET;
                        IF NOT SalesSetup."Allow Alter Posting Groups" THEN
                            ERROR(LabelPstGrChanging, FIELDCAPTION("Customer Posting Group"),
                              SalesSetup.FIELDCAPTION("Allow Alter Posting Groups"), SalesSetup.TABLECAPTION);
                        UserSetup.GET(USERID);
                        IF NOT UserSetup."Change Agreem. Posting Group" THEN
                            ERROR(LabelPstGrChanging, FIELDCAPTION("Customer Posting Group"),
                              UserSetup.FIELDCAPTION("Change Agreem. Posting Group"), UserSetup.TABLECAPTION);
                    END;
                END;
            end;
        }


        /*
        field(70058; "Installment plan 1 Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Investment Agreement LIne"."Installment plan" WHERE ("Agreement No."=FIELD("No."), "Customer No."=FIELD("Customer No.")));
            Description = 'BF 6.0.0';
            Caption = 'Installment amount (holders 1)';
            trigger OnValidate()
            begin
                CalcAmount;
            end;
        }

        field(70059; "Installment plan 2 Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Investment Agreement LIne"."Installment plan" WHERE ("Agreement No."=FIELD("No."), "Customer No."=FIELD("Customer 2 No.")));
            Description = 'BF 6.0.0';
            Caption = 'Installment amount (holders 2)';
            trigger OnValidate()
            begin
                CalcAmount;
            end;
        }

        field(70060; "Installment plan 3 Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Investment Agreement LIne"."Installment plan" WHERE ("Agreement No."=FIELD("No."), "Customer No."=FIELD("Customer 3 No.")));
            Description = 'BF 6.0.0';
            Caption = 'Installment amount (holders 3)';
            trigger OnValidate()
            begin
                CalcAmount;
            end;
        }
        */

        field(50011; "C1 Place and BirthDate"; Text[130])
        {
            Caption = 'Birthdate and palce';
        }
        field(50700; "CRM GUID"; GUID)
        {
            Editable = false;
        }

        field(70001; "Agreement Type"; Option)
        {
            Caption = 'Agreement type';
            OptionCaption = 'Sale Agreement,Iinvestment Agreement, Reservation Agreement,Inv. Sales Agreement,Service,Prev Inv. Sales Agreement,Transfer of rights';
            OptionMembers = "Sale Agreement","Investment Agreement","Reserving Agreement","Inv. Sales Agreement",Service,"Prev Inv. Sales Agreement","Transfer of rights";
        }

        field(70003; "Object of Investing"; Code[20])
        {
            TableRelation = "Investment Object"."Object No.";
            Caption = 'Object of Investing';
            trigger OnValidate()
            var
                lrObjects: Record "Investment Object";
            begin
                /*
                BC Temp
                IF grObjects.GET("Object of Investing") THEN
                BEGIN
                  IF grObjects."Sales Status" <> grObjects."Sales Status"::Freely THEN
                    ERROR(STRSUBSTNO(Text010,"Object of Investing"));

                  IF grObjects."Sales Status"<>grObjects."Sales Status"::Booked THEN
                  BEGIN
                    grObjects.VALIDATE("Sales Status",grObjects."Sales Status"::"In registration");
                    IF grObjects.GET("Object of Investing") THEN
                    BEGIN
                      grObjects."Sales Status":=grObjects."Sales Status"::"In registration";
                      grObjects.MODIFY;
                    END;
                  END
                  ELSE
                  BEGIN

                    grObjects.VALIDATE("Sales Status",grObjects."Sales Status"::"In registration");
                    IF grObjects.GET("Object of Investing") THEN
                    BEGIN
                      grObjects."Sales Status":=grObjects."Sales Status"::"In registration";
                      grObjects.MODIFY;
                    END;

                    grCustAgr.SETRANGE("Object of Investing","Object of Investing");
                    grCustAgr.SETRANGE(Status,grCustAgr.Status::Signed);
                    IF grCustAgr.FIND('-') THEN
                    BEGIN
                      grCustAgr.VALIDATE(Status,grCustAgr.Status::Cancelled);
                      grCustAgr.MODIFY;
                    END;
                  END;
                  "Project Dimension Code":=grObjects."Project Dimension Code";

                  "Building project Code":=grObjects."Building project Code";
                  "Building turn Code":=grObjects."Building turn Code";
                  "House Code":=grObjects."House Code";
                  "Section Code":=grObjects."Section Code";
                  "Object Type":=grObjects.Type;
                  "Rooms Count":=grObjects.Rooms;
                  "Total Area":=grObjects."Total area (Project)";
                  grBuildingturn.GET(grObjects."Building turn Code");
                  IF grBuildingturn."Turn Dimension Code"<>'' THEN
                  BEGIN
                    "Global Dimension 1 Code":=grBuildingturn."Turn Dimension Code";
                  END;
                END
                ELSE
                BEGIN
                  "Building project Code":='';
                  "Building turn Code":='';
                  "House Code":='';
                  "Section Code":='';
                  "Project Dimension Code":='';
                  "Global Dimension 1 Code":='';
                  "Rooms Count":='';
                  "Total Area":=0;

                END;

                UpdateLines(4);

                IF ("Object of Investing" <> xRec."Object of Investing") THEN
                  IF grObjects.GET(xRec."Object of Investing") THEN
                  BEGIN
                    grObjects.VALIDATE("Sales Status",grObjects."Sales Status"::Freely);
                    IF grObjects.GET(xRec."Object of Investing") THEN
                    BEGIN
                      grObjects."Sales Status":=grObjects."Sales Status"::Freely;
                      grObjects.MODIFY;
                    END;
                  END;

                CalcAmount;

                IF grObjects.GET("Object of Investing") THEN
                BEGIN
                  grDevelopmentSetup.GET;
                  grDefDim.SETRANGE("Table ID",14902);
                  grDefDim.SETRANGE("No.","No.");
                  grDefDim.SETRANGE("Dimension Code",grDevelopmentSetup."Project Dimension Code");
                  IF grDefDim.FIND('-') THEN
                  BEGIN
                    grDefDim.DELETE;
                  END;

                  grDefDim.SETRANGE("Table ID",14902);
                  grDefDim.SETRANGE("No.","No.");
                  grDefDim.SETRANGE("Dimension Code",grDevelopmentSetup."Project Turn Dimension Code");
                  IF grDefDim.FIND('-') THEN
                  BEGIN
                    grDefDim.DELETE;
                  END;

                  grBuildingturn.GET(grObjects."Building turn Code");
                  IF grBuildingturn."Turn Dimension Code"<>'' THEN
                  BEGIN
                    grDefDim.INIT;
                    grDefDim."Table ID":=14902;
                    grDefDim."No.":="No.";
                    grDefDim."Dimension Code":=grDevelopmentSetup."Project Turn Dimension Code";
                    grDefDim."Dimension Value Code":=grBuildingturn."Turn Dimension Code";
                    IF grDefDim.INSERT THEN;
                  END;


                  grBuildingProect.GET(grObjects."Building project Code");
                  IF grBuildingProect."Project Dimension Code"<>'' THEN
                  BEGIN
                    grDefDim.INIT;
                    grDefDim."Table ID":=14902;
                    grDefDim."No.":="No.";
                    grDefDim."Dimension Code":=grDevelopmentSetup."Project Dimension Code";
                    grDefDim."Dimension Value Code":=grBuildingProect."Project Dimension Code";
                    IF grDefDim.INSERT THEN;
                  END;
                END
                ELSE
                BEGIN
                  grDevelopmentSetup.GET;
                  grDefDim.SETRANGE("Table ID",14902);
                  grDefDim.SETRANGE("No.","No.");
                  grDefDim.SETRANGE("Dimension Code",grDevelopmentSetup."Project Dimension Code");
                  IF grDefDim.FIND('-') THEN
                  BEGIN
                    grDefDim.DELETE;
                  END;

                  grDefDim.SETRANGE("Table ID",14902);
                  grDefDim.SETRANGE("No.","No.");
                  grDefDim.SETRANGE("Dimension Code",grDevelopmentSetup."Project Turn Dimension Code");
                  IF grDefDim.FIND('-') THEN
                  BEGIN
                    grDefDim.DELETE;
                  END;
                END;
                */
            end;

        }

        field(70004; "Agreement Amount"; Decimal)
        {
            Caption = 'Agreement amount';
            BlankZero = true;

        }


        field(70005; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Procesed,Signed,Change conditions,FRS registration,FRS registered,Registration of annulled,Annulled registered,Annulled,Cancelled';
            OptionMembers = Procesed,Signed,"Change conditions","FRS registration","FRS registered","Registration of annulled","Annulled registered",Annulled,Cancelled;
            trigger OnValidate()
            begin
                //BC
                //UpdateLines(2);
            end;
        }

        field(70006; "Agreement Sub Type"; Option)
        {
            Caption = 'Invest agreement type';
            OptionCaption = 'Basic,Additional agreement';
            OptionMembers = Basic,Additional;
        }

        field(70011; "Contact 1"; Code[20])
        {
            TableRelation = Contact;
            Caption = 'Owner 1';
            trigger OnValidate()
            var
                grContact: Record Contact;
            begin
                if grContact.GET("Contact 1") then begin
                    "C1 name" := grContact.Name;
                    "C1 Passport No." := grContact."Passport No.";
                    "C1 Passport Series" := grContact."Passport Series";
                    "C1 Delivery of passport" := grContact."Delivery of passport";
                    "C1 Registration" := grContact.Registration;
                    "C1 Telephone" := grContact."Phone No.";
                    "C1 E-Mail" := COPYSTR(grContact."E-Mail", 1, MAXSTRLEN("C1 E-Mail"));
                end else begin
                    "C1 name" := '';
                    "C1 Passport No." := '';
                    "C1 Passport Series" := '';
                    "C1 Delivery of passport" := '';
                    "C1 Registration" := '';
                    "C1 Telephone" := '';
                    "C1 E-Mail" := '';
                END
            end;
        }



        field(70012; "Contact 2"; Code[20])
        {
            TableRelation = Contact;
            Caption = 'Owner 2';
            trigger OnValidate()
            var
                grContact: Record Contact;
            begin
                IF grContact.GET("Contact 2") then begin
                    "C2 name" := grContact.Name;
                    "C2 Passport No." := grContact."Passport No.";
                    "C2 Passport Series" := grContact."Passport Series";
                    "C2 Delivery of passport" := grContact."Delivery of passport";
                    "C2 Registration" := grContact.Registration;
                    "C2 Telephone" := grContact."Phone No.";
                    "C2 E-Mail" := COPYSTR(grContact."E-Mail", 1, MAXSTRLEN("C2 E-Mail"));
                    ;
                end else begin
                    "C2 name" := '';
                    "C2 Passport No." := '';
                    "C2 Passport Series" := '';
                    "C2 Delivery of passport" := '';
                    "C2 Registration" := '';
                    "C2 Telephone" := '';
                    "C2 E-Mail" := '';
                END
            end;
        }

        field(70013; "Amount part 1"; Decimal)
        {
            Caption = 'Contribution Owner 1';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 1 Amount" := ROUND("Apartment Amount" * ("Amount part 1" / 100), 1);
            end;


        }

        field(70014; "Amount part 2"; Decimal)
        {
            Caption = 'Contribution Owner 2';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 2 Amount" := ROUND("Apartment Amount" * ("Amount part 2" / 100), 1);
            end;
        }

        field(70015; "Customer 2 No."; Code[20])
        {
            TableRelation = Customer;
            Caption = 'Customer 2 No.';
            trigger OnValidate()
            var
                ContBusRel: Record "Contact Business Relation";
            begin
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SETRANGE("No.", "Customer 2 No.");
                if ContBusRel.FIND('-') then begin
                    VALIDATE("Contact 2", ContBusRel."Contact No.");
                end else
                    VALIDATE("Contact 2", '');
            end;
        }


        field(70018; "Customer 1 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer 1 Name';
        }

        field(70019; "Customer 2 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer 2 No.")));
            Caption = 'Customer 2 Name';
        }

        field(70020; "C1 Passport No."; Code[20])
        {
            Caption = 'Passport No.';
        }

        field(70021; "C1 Delivery of passport"; Text[245])
        {
            Caption = 'Passport issued';
        }

        field(70022; "C1 Registration"; Text[245])
        {
            Caption = 'Registration Address';
        }

        field(70023; "C1 Telephone"; Text[30])
        {
            Caption = 'Phone';
        }

        field(70024; "C1 Telephone 1"; Text[30])
        {
            Caption = 'Phone Home';
        }

        field(70025; "C1 E-Mail"; Text[30])
        {
            Caption = 'Email';
        }

        field(70026; "C1 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact.Name WHERE("No." = FIELD("Contact 1")));
            Caption = 'Name';
        }

        field(70027; "C2 Passport No."; Code[20])
        {
            Caption = 'Passport No.';
        }

        field(70028; "C2 Delivery of passport"; Text[245])
        {
            Caption = 'Passport issued';
        }

        field(70029; "C2 Registration"; Text[245])
        {
            Caption = 'Registration Adress';
        }

        field(70030; "C2 Telephone"; Text[30])
        {
            Caption = 'Phone';
        }

        field(70032; "C2 E-Mail"; Text[30])
        {
            Caption = 'Email';
        }

        field(70033; "C2 name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact.Name WHERE("No." = FIELD("Contact 2")));
            Caption = 'Name';
        }

        field(70034; "Amount part 1 Amount"; Decimal)
        {
            Caption = 'Contribution Amount';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 1" := ("Amount part 1 Amount" / "Apartment Amount") * 100;
            end;
        }

        field(70035; "Amount part 2 Amount"; Decimal)
        {
            Caption = 'Contribution Amount';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 2" := ("Amount part 2 Amount" / "Apartment Amount") * 100;
            end;
        }

        field(70036; "Balance Cust 1 (LCY)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Customer No." = FIELD("Customer No."), "Agreement No." = FIELD("No.")));
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
            Caption = 'Balance owner 1 (LCY)';

        }

        field(70037; "Balance Cust 2 (LCY)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Customer No." = FIELD("Customer 2 No."), "Agreement No." = FIELD("No.")));
            Editable = false;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance owner 2 (LCY)';
        }
        field(70041; "Share in property 3"; Option)
        {
            Caption = 'Share in property';
            OptionCaption = 'No,Two shareholders,Three shareholders,Four shareholders,Five shareholders';
            OptionMembers = pNo,Owner2,Owner3,Owner4,Owner5;

        }

        field(70042; "Contact 3"; Code[20])
        {
            TableRelation = Contact;
            Caption = 'Owner 3';
            trigger OnValidate()
            var
                grContact: Record Contact;
            begin
                if grContact.GET("Contact 3") then begin
                    "C3 name" := grContact.Name;
                    "C3 Passport №" := grContact."Passport No.";
                    "C3 Passport Series" := grContact."Passport Series";
                    "C3 Delivery of passport" := grContact."Delivery of passport";
                    //NC 42892 HR beg
                    //"C3 Registration":=grContact.Registration;
                    "C3 Registration" := COPYSTR(grContact.Registration, 1, MAXSTRLEN("C3 Registration"));
                    //NC 42892 HR end
                    "C3 Telephone" := grContact."Phone No.";
                    "C3 E-Mail" := COPYSTR(grContact."E-Mail", 1, MAXSTRLEN("C3 E-Mail"));
                end else begin
                    "C3 name" := '';
                    "C3 Passport №" := '';
                    "C3 Passport Series" := '';
                    "C3 Delivery of passport" := '';
                    "C3 Registration" := '';
                    "C3 Telephone" := '';
                    "C3 E-Mail" := '';
                end;
            end;
        }

        field(70043; "Amount part 3"; Decimal)
        {
            Caption = 'Contribution Owner 3';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 3 Amount" := ROUND("Apartment Amount" * ("Amount part 3" / 100), 1);
            end;
        }

        field(70044; "Customer 3 No."; Code[20])
        {
            TableRelation = Customer;
            Description = 'BF 6.0.0';
            Caption = 'Customer 2 No.';
            trigger OnValidate()
            var
                ContBusRel: Record "Contact Business Relation";
            begin
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SETRANGE("No.", "Customer 3 No.");
                IF ContBusRel.FIND('-') THEN BEGIN
                    VALIDATE("Contact 3", ContBusRel."Contact No.");
                END
                ELSE
                    VALIDATE("Contact 3", '');
            end;
        }
        field(70045; "Customer 3 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer 3 No.")));
            Caption = 'Customer 3 Name';

        }

        field(70046; "C3 Passport №"; Code[20])
        {
            Caption = 'Passport No.';
        }


        field(70047; "C3 Delivery of passport"; Text[200])
        {
            Caption = 'Passport issued';
        }


        field(70048; "C3 Registration"; Text[40])
        {
            Caption = 'Registration Address';
        }

        field(70049; "C3 Telephone"; Text[30])
        {
            Caption = 'Phone';
        }

        field(70051; "C3 E-Mail"; Text[30])
        {
            Caption = 'Email';
        }

        field(70052; "C3 name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact.Name WHERE("No." = FIELD("Contact 3")));
            Caption = 'Name';
        }


        field(70053; "Amount part 3 Amount"; Decimal)
        {
            Caption = 'Contribution Amount';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 3" := ("Amount part 3 Amount" / "Apartment Amount") * 100;
            end;
        }
        field(70054; "Balance Cust 3 (LCY)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Customer No." = FIELD("Customer 3 No."), "Agreement No." = FIELD("No.")));
            Editable = false;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance owner 3 (LCY)';

        }

        field(70055; "Installment plan 1 %"; Decimal)
        {
            Caption = 'Installment % (shareholder 1)';
            BlankZero = true;
        }

        field(70056; "Installment plan 2 %"; Decimal)
        {
            Caption = 'Installment % (shareholder 2)';
            BlankZero = true;
        }

        field(70057; "Installment plan 3 %"; Decimal)
        {
            Caption = 'Installment % (shareholder 3)';
            BlankZero = true;
        }

        field(70061; "Apartment Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Cost object (RUB)';
        }

        field(70062; "Installment Plan Amount"; Decimal)
        {
            Caption = 'Cost installment (RUB)';
            trigger OnValidate()
            begin
                //hr bc^
                //CalcAmount;
            end;
        }

        field(70080; "Payment Type"; Option)
        {
            Caption = 'Payment type';
            OptionCaption = '100%,Inv,Ipot';
            OptionMembers = "100%",Inv,Ipot;

        }

        field(70086; "C1 Passport Series"; Code[20])
        {
            Caption = 'Passport Series';
        }

        field(70087; "C2 Passport Series"; Code[20])
        {
            Caption = 'Passport Series';
        }

        field(70088; "C3 Passport Series"; Code[20])
        {
            Caption = 'Passport Series';
        }

        field(70094; "Including Finishing Price"; Decimal)
        {
            Caption = 'Including Finishing Price';
            trigger OnValidate()
            begin
                //SWC711 KAE >>
                IF "Including Finishing Price" > 0 THEN
                    VALIDATE(Finishing, TRUE)
                ELSE
                    VALIDATE(Finishing, FALSE);
                //SWC711 KAE <<
            end;
        }

        field(70095; Finishing; Boolean)
        {
            Caption = 'Finishing';
        }

        field(71020; "Old Customer No."; Code[20])
        {
            Caption = 'Old Customer No.';

        }

        field(72000; "Contact 4"; Code[20])
        {
            TableRelation = Contact;
            Caption = 'Owner 4';
            trigger OnValidate()
            var
                grContact: Record Contact;
            begin
                IF grContact.GET("Contact 4") THEN BEGIN
                    "C4 name" := grContact.Name;
                    "C4 Telephone" := grContact."Phone No.";
                END ELSE BEGIN
                    "C4 name" := '';
                    "C4 Telephone" := '';
                END
            end;
        }

        field(72010; "Amount part 4"; Decimal)
        {
            Caption = 'Contribution Owner 4';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 4 Amount" := ROUND("Apartment Amount" * ("Amount part 4" / 100), 1);
            end;
        }

        field(72020; "Customer 4 No."; Code[20])
        {
            TableRelation = Customer;
            Caption = 'Customer 4 No.';
            trigger OnValidate()
            var
                ContBusRel: Record "Contact Business Relation";
            begin
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SETRANGE("No.", "Customer 4 No.");
                IF ContBusRel.FIND('-') then begin
                    VALIDATE("Contact 4", ContBusRel."Contact No.");
                end else
                    VALIDATE("Contact 4", '');
            end;
        }

        field(72030; "Customer 4 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer 4 No.")));
            Caption = 'Customer 4 Name';
        }

        field(72040; "C4 Telephone"; Text[30])
        {
            Caption = 'Phone';
        }

        field(72050; "C4 name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact.Name WHERE("No." = FIELD("Contact 4")));
            Caption = 'Name';
        }

        field(72060; "Amount part 4 Amount"; Decimal)
        {
            Caption = 'Contribution Amount';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 4" := ("Amount part 4 Amount" / "Apartment Amount") * 100;
            end;
        }

        field(72070; "Balance Cust 4 (LCY)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Customer No." = FIELD("Customer 4 No."), "Agreement No." = FIELD("No.")));
            Editable = false;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance owner 4 (LCY)';
        }

        field(72100; "Contact 5"; Code[20])
        {
            TableRelation = Contact;
            Caption = 'Owner 5';
            trigger OnValidate()
            var
                grContact: Record Contact;
            begin
                IF grContact.GET("Contact 5") THEN BEGIN
                    "C5 name" := grContact.Name;
                    "C5 Telephone" := grContact."Phone No.";
                END ELSE BEGIN
                    "C5 name" := '';
                    "C5 Telephone" := '';
                END
            end;
        }

        field(72110; "Amount part 5"; Decimal)
        {
            Caption = 'Contribution Owner 5';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 5 Amount" := ROUND("Apartment Amount" * ("Amount part 5" / 100), 1);
            end;
        }

        field(72120; "Customer 5 No."; Code[20])
        {
            TableRelation = Customer;
            Description = 'SWC1117';
            Caption = 'Customer 5 No.';
            trigger OnValidate()
            var
                ContBusRel: Record "Contact Business Relation";
            begin
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SETRANGE("No.", "Customer 5 No.");
                if ContBusRel.FIND('-') then begin
                    VALIDATE("Contact 5", ContBusRel."Contact No.");
                end else
                    VALIDATE("Contact 5", '');
            end;
        }

        field(72130; "Customer 5 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer 5 No.")));
            Caption = 'Customer 5 Name';
        }

        field(72140; "C5 Telephone"; Text[30])
        {
            Caption = 'Phone';
        }

        field(72150; "C5 Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact.Name WHERE("No." = FIELD("Contact 5")));
            Caption = 'Name';
        }

        field(72160; "Amount part 5 Amount"; Decimal)
        {
            Caption = 'Contribution Amount';
            BlankZero = true;
            trigger OnValidate()
            begin
                "Amount part 5" := ("Amount part 5 Amount" / "Apartment Amount") * 100;
            end;
        }

        field(72170; "Balance Cust 5 (LCY)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Customer No." = FIELD("Customer 5 No."), "Agreement No." = FIELD("No.")));
            Editable = false;
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Balance owner 5 (LCY)';

        }

        field(80010; "Version Id"; Text[40])
        {
            Caption = 'Version Id';
        }


    }

    keys
    {
        key(key70000; "CRM GUID") { }

    }

}
