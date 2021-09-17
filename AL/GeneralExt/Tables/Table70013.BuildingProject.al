table 70013 "Building Project"
{
    Caption = 'Building project';
    //DataCaptionFields = "Development Setup";
    DataClassification = CustomerContent;
    //DrillDownPageID = 70070;
    //LookupPageID = 70070;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        // field(2; Descriotion; Text[250])
        // {
        //     Caption = 'Description';
        // }
        // field(3; "Build address"; Text[250])
        // {
        //     Caption = 'Build address';
        // }
        // field(4; "Police address"; Text[250])
        // {
        //     Caption = 'Policy Adress';
        // }
        // field(5; "Starting Date"; Date)
        // {
        //     Caption = 'Start Date';
        // }
        // field(6; "Ending Date (Plan)"; Date)
        // {
        //     Caption = 'Delivery Date';
        // }
        // field(7; "Ending Date"; Date)
        // {
        //     Caption = 'Delivery Date (fact)';
        // }
        // field(10; "Total area (Project)"; Decimal)
        // {
        //     CalcFormula = Sum("Apartments"."Total area (Project)" where("Building project Code" = field(Code)));
        //     Caption = 'Total area (projected)';
        //     //            RUS='Общая площадь (проектная)';
        //     FieldClass = FlowField;
        // }
        // field(11; "Total area (PIB)"; Decimal)
        // {
        //     CalcFormula = Sum(Apartments."Total area (PIB)" where("Building project Code" = field(Code)));
        //     Caption = 'Total area (PIB)';
        //     //            RUS='Общая площадь (ПИБ)';
        //     FieldClass = FlowField;
        // }
        // field(12; "Total area (Project resulted)"; Decimal)
        // {
        //     CalcFormula = Sum(Apartments."Total area (Project resulted)" where("Building project Code" = field(Code)));
        //     Caption = 'Total area (projected reduced)';
        //     //            RUS='Общая площадь (проектная приведенная)';
        //     FieldClass = FlowField;
        // }
        // field(13; "Total area (ПИБ resulted)"; Decimal)
        // {
        //     CalcFormula = Sum(Apartments."Total area (ПИБ resulted)" where("Building project Code" = field(Code)));
        //     Caption = 'Total area (PIB reduced)';
        //     //            RUS='Общая площадь (ПИБ приведенная)';
        //     FieldClass = FlowField;
        // }
        // field(14; "Map link"; Text[250])
        // {
        //     Caption = 'Map reference';
        // }
        // field(15; "Building turn"; Integer)
        // {
        //     CalcFormula = Count("Building turn" where("Building project Code" = field(Code)));
        //     Caption = 'Construction Queue';
        //     //            RUS='Очереди строительства';
        //     FieldClass = FlowField;
        // }
        // field(16; Houses; Integer)
        // {
        //     CalcFormula = Count(House where("Building project Code" = field(Code)));
        //     Caption = 'Building';
        //     //            RUS='Домов';
        //     FieldClass = FlowField;
        // }
        // field(17; Apartments; Integer)
        // {
        //     CalcFormula = Count(Apartments where("Building project Code" = field(Code)));
        //     Caption = 'Apartmens';
        //     //            RUS='Квартир';
        //     FieldClass = FlowField;
        // }
        // field(18; Sections; Integer)
        // {
        //     CalcFormula = Count(Sections where("Building project Code" = field(Code)));
        //     FieldClass = FlowField;
        // }
        // field(19; "Number of Storeys From"; Integer)
        // {
        //     Caption = 'Number of Storeys From';
        // }
        // field(20; "Number of Storeys To"; Integer)
        // {
        //     Caption = 'Number of Storeys To';
        // }
        // field(21; "Available in sales"; Boolean)
        // {
        //     Caption = 'Available in sales';
        // }
        // field(22; "Dev. Starting Date"; Date)
        // {
        //     Caption = 'Start date';
        // }
        field(23; "Dev. Ending Date"; Date)
        {
            Caption = 'End date';
        }
        // field(24; "Dev. Ending Date (Fact)"; Date)
        // {
        //     Caption = 'Ending date';
        // }
        // field(25; "Creating Date"; Date)
        // {
        //     Caption = 'Create date';
        // }
        // field(26; Status; Option)
        // {
        //     Caption = 'Status';
        //     InitValue = "Order";
        //     OptionCaption = 'Planning,Quote,Order,Completed';
        //     OptionMembers = Planning,Quote,Order,Completed;
        // }
        // field(27; "Person Responsible"; Code[20])
        // {
        //     Caption = 'Person Responsible';
        //     TableRelation = "Salesperson/Purchaser";
        // }
        field(28; "Project Dimension Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';

            trigger OnLookup()
            begin
                grDevSetup.Get;
                grDevSetup.TestField("Project Dimension Code");

                grDimValue.SetRange("Dimension Code", grDevSetup."Project Dimension Code");
                if grDimValue.Find('-') then begin
                    if Page.RunModal(Page::"Dimension Values", grDimValue) = Action::LookupOK then
                        "Project Dimension Code" := grDimValue.Code;
                end;
            end;
        }
        // field(29; Blocked; Option)
        // {
        //     Caption = 'Blocked';
        //     OptionCaption = ' ,Posting,All';
        //     OptionMembers = " ",Posting,All;
        // }
        // field(30; "Last Date Modified"; Date)
        // {
        //     Caption = 'Last Date Modified';
        //     Editable = false;
        // }
        // field(31; Picture; Blob)
        // {
        //     Caption = 'Picture';
        //     SubType = Bitmap;
        // }
        // field(32; "Currency Code"; Code[10])
        // {
        //     Caption = 'Currency Code';
        //     TableRelation = Currency;
        // }
        // field(33; Complete; Boolean)
        // {
        //     Caption = 'Complete';
        // }
        // field(34; "Location Code"; Code[20])
        // {
        //     Caption = 'Location Code';
        //     TableRelation = Location where("Use As In-Transit" = const(false));
        // }
        field(35; "General Contractor No."; Code[20])
        {
            Caption = 'General Contrator';
            TableRelation = Vendor;

            trigger OnValidate();
            begin
                if "General Contractor No." <> xRec."General Contractor No." then
                    "Gen. Contractor Agreement" := '';
                if grVendor.Get("General Contractor No.") then begin
                    "General Contractor Name" := grVendor.Name;
                    "General Contractor Adres" := grVendor.Address;
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Vendor);
                    ContBusRel.SetRange("No.", "General Contractor No.");
                    if ContBusRel.Find('-') then begin
                        Validate("Gen. Contractor Contact No.", ContBusRel."Contact No.");
                    end;
                END
                ELSE begin
                    "General Contractor Name" := '';
                    "General Contractor Adres" := '';
                    Validate("Gen. Contractor Contact No.", '');
                end;
            end;
        }
        field(36; "General Contractor Name"; Text[250])
        {
            Caption = 'General Contrator Name';
        }
        field(37; "Gen. Contractor Contact No."; Code[20])
        {
            Caption = 'General Contrator Contact No.';
            TableRelation = Contact;
        }
        field(38; "General Contractor Adres"; Text[250])
        {
            Caption = 'General Contrator Adress';
        }
        field(39; "Gen. Contractor Agreement"; Code[20])
        {
            Caption = 'General Contrator Agreement';
            TableRelation = "Vendor Agreement"."No." where("Vendor No." = field("General Contractor No."));
        }
        //  field(60088; "Original Company"; Code[2])
        // {
        //     Caption = 'Original Company';
        // }
        // field(70001; Comments; Boolean)
        // {
        //     CalcFormula = Exist("Comment Line" where("Table Name" = const(17), "No." = field(Code)));
        //     Caption = 'Comments';
        //     FieldClass = FlowField;
        // }
        // field(70002; Attachmets; Boolean)
        // {
        //     CalcFormula = Exist("Attachment WF" where("Document Type" = const(DevObj), "Document No." = field(Code)));
        //     Caption = 'Attachments';
        //     //            RUS='Вложения';
        //     FieldClass = FlowField;
        // }
        // field(70003; Customers; Integer)
        // {
        //     Caption = 'Agreements (Client)';
        // }
        // field(70004; Vendors; Integer)
        // {
        //     Caption = 'Agreements (Vendor)';
        // }
        // field(70005; "Investment Calculation"; Integer)
        // {
        //     CalcFormula = Count("Project Version" where("Project Code" = field(Code), "Analysis Type" = const("Investment Calculation")));
        //     Caption = 'Budget';
        //     //            RUS='Бюджет';
        //     FieldClass = FlowField;
        // }
        // field(70006; "Fixed Investment Calculation"; Code[20])
        // {
        //     CalcFormula = Lookup("Project Version"."Version Code" where("Project Code" = field(Code), "Analysis Type" = const("Investment Calculation"), "Fixed Version" = const(Yes)));
        //     Caption = 'Fixing the version of Investment Calculation';
        //     //            RUS='Фиксированя версия Investment Calculation';
        //     FieldClass = FlowField;
        // }
        // field(70007; "Detailed Planning"; Integer)
        // {
        //     CalcFormula = Count("Project Version" where("Project Code" = field(Code), "Analysis Type" = const("Detailed Planning")));
        //     FieldClass = FlowField;
        // }
        // field(70008; "Fixed Detailed Planning"; Code[20])
        // {
        //     CalcFormula = Lookup("Project Version"."Version Code" where("Project Code" = field(Code), "Analysis Type" = const("Detailed Planning"), "Fixed Version" = const(Yes)));
        //     Caption = 'Fixing the version of Detailed Planning';
        //     //            RUS='Фиксированя версия Detailed Planning';
        //     FieldClass = FlowField;
        // }
        // field(70009; "Estimate Calculation"; Integer)
        // {
        //     CalcFormula = Count("Project Version" where ("Project Code" = field(Code), "Analysis Type" = const("Estimate Calculation")));
        //     FieldClass = FlowField;
        // }
        // field(70010; "Fixed Estimate Calculation"; Code[20])
        // {
        //     CalcFormula = Lookup("Project Version"."Version Code" where ("Project Code" = field(Code), "Analysis Type" = const("Estimate Calculation"), "Fixed Version" = const(Yes)));
        //     Caption = 'Fixing the version of Estimate Calculation';
        //     //            RUS='Фиксированя версия Estimate Calculation';
        //     FieldClass = FlowField;
        // }
        // field(70011; "Current Status"; Option)
        // {
        //     Caption = 'Current Status';
        //     OptionCaption = '[1] Prospect,[2] Real estate,[3] Pre-project,[4] Project,[5] Closed';
        //     OptionMembers = Prospect,Realestate,"Pre-project",Project,Closed;
        // }
        // field(70012; Tollgate; Option)
        // {
        //     Caption = 'Tollgate';
        //     OptionCaption = '[TG0] Permission for costs exceeding (50 000 SEK) for a “Prospect”,[TG1a] Investment decision,[TG1b] NCC Real Estate Object,[TG2] Start of development project,[TG3] Permission to start building and sales project,[TG4] Building start,[TG5] Building complete,[TG6] Project Closing';
        //     OptionMembers = TG0,TG1a,TG1b,TG2,TG3,TG4,TG5,TG6;
        // }
        // field(70013; "Project Dimension Range"; Text[250])
        // {
        // }
        // field(70014; "Enable Cash Flow"; Boolean)
        // {
        //     Caption = 'Enable Cash Flow';
        // }
        // field(70015; "Include Advances in Cash Flow"; Boolean)
        // {
        //     Caption = 'Include Advances in Cash Flow';
        // }
        field(70016; "Without Details"; Boolean)
        {
            Caption = 'Without Details';
        }
        // field(70017; "Housing Dimension"; Text[250])
        // {
        //     Caption = 'Housing Dimension';
        //     trigger OnLookup();
        //     begin
        //         grDevSetup.Get;
        //         grDevSetup.TestField("Project Dimension Code");

        //         grDimValue.SetRange("Dimension Code", grDevSetup."Project Dimension Code");
        //         if grDimValue.Find('-') then begin
        //             if Page.RunModal(Page::"Dimension Values", grDimValue) = ACTION::LookupOK then
        //                 "Housing Dimension" := grDimValue.Code;
        //         end
        //     end;
        // }
        field(70018; "Development/Production"; Option)
        {
            Caption = 'Development/Production';
            OptionCaption = ' ,Development,Production';
            OptionMembers = " ",Development,Production;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    var
        // Text000: label 'You cannot change %1 because one or more entries are associated with this %2.';
        // //RUS='Невозможно изменить %1, поскольку одна или несколько записей связаны с %2.';
        // Text003: label 'You must run the %1 and %2 functions to create and post the completion entries for this job.';
        // //RUS='Необходимо выполнить функции %1 и %2, чтобы создать и учесть операции частичного выполнения этого задания.';
        // Text004: label 'This will delete any unposted WIP entries for this job and allow you to reverse the completion postings for this job.\\Do you wish to continue?';
        // //RUS='При этом будут удалены любые неучтенные операции НЗП для этой работы. Система позволит отменить учет частичного выполнения этого задания.\Продолжить?';
        // Text005: label 'Contact %1 %2 is related to a different company than customer %3.';
        // //RUS='Контакт %1 %2 связан с компанией, отличной от клиента %3.';
        // Text006: label 'Contact %1 %2 is not related to customer %3.';
        // //RUS='Контакт %1 %2 не связан с клиентом %3.';
        // Text007: label 'Contact %1 %2 is not related to a customer.';
        // //RUS='Контакт %1 %2 не связан с клиентом.';
        // Text008: label '%1 %2 must not be blocked with type %3.';
        // //RUS='%1 %2 не должны блокироваться типом %3.';
        // Text009: label 'You must run the %1 function to reverse the completion entries that have already been posted for this job.';
        // //RUS='Необходимо выполнить функцию %1, чтобы отменить операции частичного выполнения, которые были учтены для этой работы.';
        grVendor: Record Vendor;
        ContBusRel: Record "Contact Business Relation";
        // grContact: Record Contact;
        // grContract: Record "Vendor Agreement";
        grDimValue: Record "Dimension Value";
        grDevSetup: Record "Development Setup";

}