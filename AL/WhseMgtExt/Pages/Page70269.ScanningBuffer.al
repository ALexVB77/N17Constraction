page 70269 ScanningBuffer
{
    
    ApplicationArea = All;
    Caption = 'ScanningBuffer';
    PageType = List;
    SourceTable = "Scanning Buffer";
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(DocumentFilter; Rec.DocumentFilter)
                {
                    ApplicationArea = All;
                }
                field(DocumentLineNo; Rec.DocumentLineNo)
                {
                    ApplicationArea = All;
                }
                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = All;
                }
                field(DocumentType; Rec.DocumentType)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Qty; Rec.Qty)
                {
                    ApplicationArea = All;
                }
                field("Qty(Base)"; Rec."Qty(Base)")
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                }
                field(Uom; Rec.Uom)
                {
                    ApplicationArea = All;
                }
                field("Uom(Base)"; Rec."Uom(Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
