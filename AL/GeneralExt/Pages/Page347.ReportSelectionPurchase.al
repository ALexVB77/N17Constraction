pageextension 80347 "Report Selection - Purch. Ext" extends "Report Selection - Purchase"
{
    layout
    {
        modify(ReportUsage2)
        {
            Visible = false;
        }
        addafter(ReportUsage2)
        {
            field(ReportUsageNew; ReportUsageNew)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Usage';
                OptionCaption = 'Quote,Blanket Order,Order,Invoice,Return Order,Credit Memo,Receipt,Return Shipment,Purchase Document - Test,Prepayment Document - Test,Archived Quote,Archived Order,Archived Return Order,Archived Blanket Order,Vendor Remittance,Vendor Remittance - Posted Entries,UnPosted Advance Statement,Advance Statement,UnPosted Invoice,UnPosted Cr. Memo,Purch. Order Act';
                ToolTip = 'Specifies which type of document the report is used for.';

                trigger OnValidate()
                begin
                    SetUsageFilterNew(true);
                end;
            }
        }
    }

    var
        ReportUsageNew: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo",Receipt,"Return Shipment","Purchase Document - Test","Prepayment Document - Test","Archived Quote","Archived Order","Archived Return Order","Archived Blanket Order","Vendor Remittance","Vendor Remittance - Posted Entries","UnPosted Advance Statement","Advance Statement","UnPosted Invoice","UnPosted Cr. Memo","Purch. Order Act";

    local procedure SetUsageFilterNew(ModifyRec: Boolean)
    begin
        if ModifyRec then
            if Modify then;
        FilterGroup(2);
        case ReportUsageNew of
            ReportUsageNew::Quote:
                SetRange(Usage, Usage::"P.Quote");
            ReportUsageNew::"Blanket Order":
                SetRange(Usage, Usage::"P.Blanket");
            ReportUsageNew::Order:
                SetRange(Usage, Usage::"P.Order");
            ReportUsageNew::Invoice:
                SetRange(Usage, Usage::"P.Invoice");
            ReportUsageNew::"Return Order":
                SetRange(Usage, Usage::"P.Return");
            ReportUsageNew::"Credit Memo":
                SetRange(Usage, Usage::"P.Cr.Memo");
            ReportUsageNew::Receipt:
                SetRange(Usage, Usage::"P.Receipt");
            ReportUsageNew::"Return Shipment":
                SetRange(Usage, Usage::"P.Ret.Shpt.");
            ReportUsageNew::"Purchase Document - Test":
                SetRange(Usage, Usage::"P.Test");
            ReportUsageNew::"Prepayment Document - Test":
                SetRange(Usage, Usage::"P.Test Prepmt.");
            ReportUsageNew::"Archived Quote":
                SetRange(Usage, Usage::"P.Arch.Quote");
            ReportUsageNew::"Archived Order":
                SetRange(Usage, Usage::"P.Arch.Order");
            ReportUsageNew::"Archived Return Order":
                SetRange(Usage, Usage::"P.Arch.Return");
            ReportUsageNew::"Archived Blanket Order":
                SetRange(Usage, Usage::"P.Arch.Blanket");
            ReportUsageNew::"Vendor Remittance":
                SetRange(Usage, Usage::"V.Remittance");
            ReportUsageNew::"Vendor Remittance - Posted Entries":
                SetRange(Usage, Usage::"P.V.Remit.");
            ReportUsageNew::"UnPosted Advance Statement":
                SetRange(Usage, Usage::UAS);
            ReportUsageNew::"Advance Statement":
                SetRange(Usage, Usage::AS);
            ReportUsageNew::"UnPosted Invoice":
                SetRange(Usage, Usage::UPI);
            ReportUsageNew::"UnPosted Cr. Memo":
                SetRange(Usage, Usage::UPCM);
            // NC AB: new values
            ReportUsageNew::"Purch. Order Act":
                SetRange(Usage, Usage::PurchOrderAct);
        end;
        FilterGroup(0);
        CurrPage.Update;
    end;

}