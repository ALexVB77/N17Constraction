page 70097 "Document Attach. Details Arch."
{
    Caption = 'Attached Documents Archive';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "Document Attachment Archive";
    SourceTableView = SORTING(ID, "Table ID");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; "File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the filename of the attachment.';

                    trigger OnDrillDown()
                    begin
                        if "Document Reference ID".HasValue then
                            Export(true);
                    end;
                }
                field("File Extension"; "File Extension")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the file extension of the attachment.';
                }
                field("File Type"; "File Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that the attachment is.';
                }
                field(User; User)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the user who attached the document.';
                }
                field("Attached Date"; "Attached Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the document was attached.';
                }
                field("Document Flow Purchase"; "Document Flow Purchase")
                {
                    ApplicationArea = All;
                    CaptionClass = GetCaptionClass(9);
                    Editable = FlowFieldsEditable;
                    ToolTip = 'Specifies if the attachment must flow to transactions.';
                    Visible = PurchaseDocumentFlow;
                }
                field("Document Flow Sales"; "Document Flow Sales")
                {
                    ApplicationArea = All;
                    CaptionClass = GetCaptionClass(11);
                    Editable = FlowFieldsEditable;
                    ToolTip = 'Specifies if the attachment must flow to transactions.';
                    Visible = SalesDocumentFlow;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Preview)
            {
                ApplicationArea = All;
                Caption = 'Preview';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Get a preview of the attachment.';

                trigger OnAction()
                begin
                    if "File Name" <> '' then
                        Export(true);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        FlowFieldsEditable := false;
    end;

    var
        FromRecRef: RecordRef;
        SalesDocumentFlow: Boolean;
        PurchaseDocumentFlow: Boolean;
        FlowToPurchTxt: Label 'Flow to Purch. Trx';
        FlowToSalesTxt: Label 'Flow to Sales Trx';
        FlowFieldsEditable: Boolean;

    local procedure GetCaptionClass(FieldNo: Integer): Text
    begin
        if SalesDocumentFlow and PurchaseDocumentFlow then
            case FieldNo of
                9:
                    exit(FlowToPurchTxt);
                11:
                    exit(FlowToSalesTxt);
            end;
    end;

    procedure OpenForRecRef(RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        LineNo: Integer;
        RecNoOccur, VerNo : Integer;
    begin
        Reset;

        FromRecRef := RecRef;

        SetRange("Table ID", RecRef.Number);

        if RecRef.Number = DATABASE::Item then begin
            SalesDocumentFlow := true;
            PurchaseDocumentFlow := true;
        end;

        case RecRef.Number of
            // SalesDocumentFlow := true;
            DATABASE::"Purchase Header Archive",
          DATABASE::"Purchase Line Archive":
                PurchaseDocumentFlow := true;
        end;

        case RecRef.Number of
            DATABASE::"Purchase Header Archive",
            DATABASE::"Purchase Line Archive":
                begin
                    FieldRef := RecRef.Field(1);
                    DocType := FieldRef.Value;
                    SetRange("Document Type", DocType);

                    FieldRef := RecRef.Field(3);
                    RecNo := FieldRef.Value;
                    SetRange("No.", RecNo);

                    FieldRef := RecRef.Field(5048);
                    RecNoOccur := FieldRef.Value;
                    SetRange("Doc. No. Occurrence", RecNoOccur);

                    FieldRef := RecRef.Field(5047);
                    VerNo := FieldRef.Value;
                    SetRange("Version No.", VerNo);

                    FlowFieldsEditable := false;
                end;
        end;

        case RecRef.Number of
            DATABASE::"Purchase Line Archive":
                begin
                    FieldRef := RecRef.Field(4);
                    LineNo := FieldRef.Value;
                    SetRange("Line No.", LineNo);
                end;
        end;
    end;
}

