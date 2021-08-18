page 70091 "Investment Agreement Card"
{
    Caption = 'Investment Agreement Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Customer Agreement";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Agreement Type"; Rec."Agreement Type")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Agreement Sub Type"; Rec."Agreement Sub Type")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("External Agreement No."; rec."External Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Agreement Date"; Rec."Agreement Date")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Expire Date"; Rec."Expire Date")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }


                field("Apartment Amount"; Rec."Apartment Amount")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Share in property 3"; Rec."Share in property 3")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }


                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Installment (LCY)"; Rec."Agreement Amount" - Rec."Apartment Amount")
                {
                    Caption = 'Installment (LCY)';
                    BlankZero = true;
                    DecimalPlaces = 2;
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Agreement Amount"; Rec."Agreement Amount")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Remaining Amount (LCY)"; Rec."Agreement Amount" + Rec."Balance (LCY)")
                {
                    Caption = 'Remaining Amount (LCY)';
                    BlankZero = true;
                    DecimalPlaces = 2;
                    Editable = false;
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("Hand over status"; gcduERPC.GetAgreementActStatus(Rec."No."))
                {
                    ApplicationArea = All;
                    Caption = 'Hand over status';
                    Editable = false;
                }

                //Shareholder 1
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Customer 1 Name"; Rec."Customer 1 Name")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field("Balance Cust 1 (LCY)"; Rec."Balance Cust 1 (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                group(Shareholder2)
                {
                    Caption = 'Shareholder 2';
                    Visible = ShareHolder2InfoVisible;
                    Editable = StatusEditableMod;

                    field("Customer 2 No."; Rec."Customer 2 No.")
                    {
                        ApplicationArea = All;
                    }

                    field("Customer 2 Name"; Rec."Customer 2 Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Balance Cust 2 (LCY)"; Rec."Balance Cust 2 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }


                group(Shareholder3)
                {
                    Caption = 'Shareholder 3';
                    Visible = ShareHolder3InfoVisible;
                    Editable = StatusEditableMod;

                    field("Customer 3 No."; Rec."Customer 3 No.")
                    {
                        ApplicationArea = All;
                    }

                    field("Customer 3 Name"; Rec."Customer 3 Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Balance Cust 3 (LCY)"; Rec."Balance Cust 3 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }


                group(Shareholder4)
                {
                    Caption = 'Shareholder 4';
                    Visible = ShareHolder4InfoVisible;
                    Editable = StatusEditableMod;

                    field("Customer 4 No."; Rec."Customer 4 No.")
                    {
                        ApplicationArea = All;
                    }

                    field("Customer 4 Name"; Rec."Customer 4 Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Balance Cust 4 (LCY)"; Rec."Balance Cust 4 (LCY)")
                    {
                        ApplicationArea = All;
                    }
                }

                group(Shareholder5)
                {
                    Caption = 'Shareholder 5';
                    Visible = ShareHolder5InfoVisible;
                    Editable = StatusEditableMod;

                    field("Customer 5 No."; Rec."Customer 5 No.")
                    {
                        ApplicationArea = All;
                    }

                    field("Customer 5 Name"; Rec."Customer 5 Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Balance Cust 5 (LCY)"; Rec."Balance Cust 5 (LCY)")
                    {
                        ApplicationArea = All;
                    }
                }


            }

            group(InvestingObject)
            {
                Caption = 'Investment object';

                field("Investing Object"; Rec."Object of Investing")
                {
                    ApplicationArea = All;
                    TableRelation = Apartments;
                    Editable = StatusEditableMod;
                    trigger OnValidate()
                    begin
                        if "Object of Investing" <> '' then
                            Apartments.GET("Object of Investing")
                        else
                            Apartments.Init;
                    end;
                }

                field("Investing Object Description"; Apartments.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                }

                field("Investing Origin Type"; Apartments."Origin Type")
                {
                    ApplicationArea = All;
                    Caption = 'Object type';
                    Editable = false;
                }

                field("Investing Object Total Area"; Apartments."Total Area (Project)")
                {
                    ApplicationArea = All;
                    Caption = 'Total Area';
                    Editable = false;
                }

                field("Apartment Amount IO"; Rec."Apartment Amount")
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;
                }

                field(Finishing; Rec.Finishing)
                {
                    ApplicationArea = All;
                    Editable = StatusEditableMod;

                }

                field("Including Finishing Price"; Rec."Including Finishing Price")
                {
                    ApplicationArea = All;
                    Visible = FinishingVisible;
                    Editable = StatusEditableMod;
                }

                field("CRM GUID"; Rec."CRM GUID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }

            group(ShareholdersDetails)
            {
                Caption = 'Shareholders details';
                Editable = StatusEditableMod;

                field("Contact 1"; Rec."Contact 1")
                {
                    ApplicationArea = All;
                }
                field("C1 Name"; Rec."C1 Name")
                {
                    ApplicationArea = All;
                }

                field("C1 Telephone"; Rec."C1 Telephone")
                {
                    ApplicationArea = All;
                }

                field("C1 Passport Series"; Rec."C1 Passport Series")
                {
                    ApplicationArea = All;
                }

                field("C1 Delivery of passport"; Rec."C1 Delivery of passport")
                {
                    ApplicationArea = All;
                }

                field("C1 Passport No."; Rec."C1 Passport No.")
                {
                    ApplicationArea = All;
                }

                field("C1 Registration"; Rec."C1 Registration")
                {
                    ApplicationArea = All;
                }

                //долевой взнос %/сумма
                field("Amount part 1"; Rec."Amount part 1")
                {
                    ApplicationArea = All;
                }
                field("Amount part 1 Amount"; rec."Amount part 1 Amount")
                {
                    ApplicationArea = All;
                }

                //рассрочка % год/сумма
                field("Installment plan 1 %"; Rec."Installment plan 1 %")
                {
                    ApplicationArea = All;
                }


                field("BalanceCust1Req"; Rec."Balance Cust 1 (LCY)")
                {
                    ApplicationArea = All;
                }

                //"Amount part 1 Amount"+"Installment plan 1 Amount"+"Balance Cust 1 (LCY)"
                field("RemainingAmtLCYReq"; Rec."Amount part 1 Amount" + Rec."Balance Cust 1 (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount';
                    Editable = false;
                }

                field("C1 Place and BirthDate"; Rec."C1 Place and BirthDate")
                {
                    ApplicationArea = All;
                }

                group(Shareholder2Req)
                {
                    Caption = 'Shareholder 2 details';
                    Visible = ShareHolder2InfoVisible;

                    field("Contact 2"; Rec."Contact 2")
                    {
                        ApplicationArea = All;
                    }

                    field("C2 name"; Rec."C2 name")
                    {
                        ApplicationArea = All;
                    }

                    field(C2TelephoneReq; Rec."C2 Telephone")
                    {
                        ApplicationArea = All;
                    }


                    field("Amount part 2"; Rec."Amount part 2")
                    {
                        ApplicationArea = All;
                    }

                    field("Amount part 2 Amount"; Rec."Amount part 2 Amount")
                    {
                        ApplicationArea = All;
                    }

                    field(BalanceCust2LCYReq; Rec."Balance Cust 2 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }

                group(Shareholder3Req)
                {
                    Caption = 'Shareholder 3 details';
                    Visible = ShareHolder5InfoVisible;

                    field("Contact 3"; Rec."Contact 3")
                    {
                        ApplicationArea = All;
                    }

                    field("C3 name"; Rec."C3 name")
                    {
                        ApplicationArea = All;
                    }

                    field(C3TelephoneReq; Rec."C3 Telephone")
                    {
                        ApplicationArea = All;
                    }


                    field("Amount part 3"; Rec."Amount part 3")
                    {
                        ApplicationArea = All;
                    }

                    field("Amount part 3 Amount"; Rec."Amount part 3 Amount")
                    {
                        ApplicationArea = All;
                    }

                    field(BalanceCust3LCYReq; Rec."Balance Cust 3 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }

                group(Shareholder4Req)
                {
                    Caption = 'Shareholder 4 details';
                    Visible = ShareHolder5InfoVisible;

                    field("Contact 4"; Rec."Contact 4")
                    {
                        ApplicationArea = All;
                    }

                    field("C4 name"; Rec."C4 name")
                    {
                        ApplicationArea = All;
                    }

                    field(C4TelephoneReq; Rec."C4 Telephone")
                    {
                        ApplicationArea = All;
                    }


                    field("Amount part 4"; Rec."Amount part 4")
                    {
                        ApplicationArea = All;
                    }

                    field("Amount part 4 Amount"; Rec."Amount part 4 Amount")
                    {
                        ApplicationArea = All;
                    }

                    field(BalanceCust4LCYReq; Rec."Balance Cust 4 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }

                group(Shareholder5Req)
                {
                    Caption = 'Shareholder 5 details';
                    Visible = ShareHolder5InfoVisible;

                    field("Contact 5"; Rec."Contact 5")
                    {
                        ApplicationArea = All;
                    }

                    field("C5 name"; Rec."C5 name")
                    {
                        ApplicationArea = All;
                    }

                    field(C5TelephoneReq; Rec."C5 Telephone")
                    {
                        ApplicationArea = All;
                    }

                    field("Amount part 5"; Rec."Amount part 5")
                    {
                        ApplicationArea = All;
                    }

                    field("Amount part 5 Amount"; Rec."Amount part 5 Amount")
                    {
                        ApplicationArea = All;
                    }

                    field(BalanceCust5LCYReq; Rec."Balance Cust 5 (LCY)")
                    {
                        ApplicationArea = All;
                    }

                }


            }

            group(Invoicing)
            {
                Caption = 'Invoicing';
                Editable = StatusEditableMod;

                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }

                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }

                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                }


            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("A&greement")
            {
                Caption = 'A&greement';
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = GL;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("Customer No."),
                                  "Agreement No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Customer Agreement"),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(14902),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }

                action("Entry Statistics")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Entry Statistics';
                    Image = EntryStatistics;
                    RunObject = Page "Customer Entry Statistics";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                    ToolTip = 'View entry statistics for the record.';
                }
                action("S&ales")
                {
                    ApplicationArea = Suite;
                    Caption = 'S&ales';
                    Image = Sales;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Sales";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                }
                action(Attachments)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }

            }
            group(Action82)
            {
                Caption = 'S&ales';
                Image = Sales;

                action(Orders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Sales Order List";
                    RunPageLink = "Sell-to Customer No." = FIELD("Customer No."),
                                  "Agreement No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Sell-to Customer No.", "No.");
                    ToolTip = 'View any related sales orders. ';
                }

            }
        }

    }

    trigger OnAfterGetRecord()
    begin

        StatusEditableMod := Rec.Status in [Rec.Status::Procesed, Rec.Status::"Change conditions"];

        if "Object of Investing" <> '' then
            Apartments.GET("Object of Investing")
        else
            Apartments.Init;

        ShareHolder2InfoVisible := Rec."Share in property 3" = rec."Share in property 3"::Owner2;
        ShareHolder3InfoVisible := Rec."Share in property 3" = rec."Share in property 3"::Owner3;
        ShareHolder4InfoVisible := Rec."Share in property 3" = rec."Share in property 3"::Owner4;
        ShareHolder5InfoVisible := Rec."Share in property 3" = rec."Share in property 3"::Owner5;
        FinishingVisible := Finishing;
    end;

    trigger OnNewRecord(BelowxRec: boolean)
    begin
        Rec."Agreement Type" := "Agreement Type"::"Investment Agreement";
    end;

    trigger OnDeleteRecord(): boolean
    begin
        //BC to-do
        //IF NOT CanDelete THEN ERROR(TEXT0007);
    end;

    trigger OnOpenPage()
    begin
    end;


    var
        Apartments: Record Apartments;
        gcduERPC: Codeunit "ERPC Funtions";
        ShareHolder2InfoVisible: Boolean;
        ShareHolder3InfoVisible: Boolean;
        ShareHolder4InfoVisible: Boolean;
        ShareHolder5InfoVisible: Boolean;

        FinishingVisible: Boolean;

        StatusEditableMod: Boolean;

}
