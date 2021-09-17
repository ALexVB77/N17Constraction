page 70009 "Giv. Prod. Order"
{

    Caption = 'Giv. Prod. Order';
    PageType = Document;
    SourceTable = "Giv. Prod. Order";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field(Finished; Rec.Finished)
                {
                    ApplicationArea = All;
                }
            }
            group(Parts)
            {
                part(ShpmtHdr; "Giv. Prod. Order Shipment")
                {
                    ApplicationArea = all;
                    SubPageLink = "Order No." = FIELD("No.");
                    UpdatePropagation = Both;
                }
                part(ShpmtLines; "Posted Item Shipment Subform")
                {
                    ApplicationArea = all;
                    UpdatePropagation = Both;
                }
            }
            group(Release)
            {
                part(RcptHdr; "Giv. Prod. Order Receipt")
                {
                    ApplicationArea = all;
                    SubPageLink = "Order No." = FIELD("No.");
                    UpdatePropagation = Both;
                }
                part(RcptLinesUnposted; "Item Receipt Subform")
                {
                    ApplicationArea = all;
                    UpdatePropagation = Both;
                }
                part(RcptLinesPosted; "Posted Item Receipt Subform")
                {
                    ApplicationArea = all;
                    UpdatePropagation = Both;
                }
            }
            group(Jobs)
            {
                part(JobHdr; "Giv. Prod. Order Job")
                {
                    ApplicationArea = all;
                    SubPageLink = "Order No." = FIELD("No.");
                    UpdatePropagation = Both;
                }
                part(JobLinesInv; "Posted Purch. Invoice Subform")
                {
                    ApplicationArea = all;
                    UpdatePropagation = Both;
                }
                part(JobLinesCrMemo; "Posted Purch. Cr. Memo Subform")
                {
                    ApplicationArea = all;
                    UpdatePropagation = Both;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        ism.init();
        ism.setBool('ListenEvents', true);
    end;

    var
        ism: Codeunit "Isolated Storage Management GE";

}
