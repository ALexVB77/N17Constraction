pageextension 92451 "Item Receipt Subform (Ext)" extends "Item Receipt Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
            {
                ApplicationArea = All;
                Description = 'NC 50113 EP';
            }
        }
        addLast(Content)
        {
            //group(UserControlTimer)
            //{
            usercontrol(D365BCPingPong; D365BCPingPong)
            {
                applicationarea = all;
                trigger TimerElapsed()
                var
                    docNo: text;
                    postedRcpt: Boolean;
                begin
                    currpage.D365BCPingPong.StopTimer();
                    if ism.getBool('p50030_PostedRcpt', postedRcpt, false) then begin
                        if not postedRcpt then begin
                            ism.delValue('p50030_PostedRcpt');
                            ism.getString('p50030_DocNo', docNo, true);
                            filterRecords(docNo);
                        end;
                    end;
                    CurrPage.D365BCPingPong.StartTimer();
                end;
            }
            //}
        }
    }
    trigger OnOpenPage()
    begin
        ism.getBool('ListenEvents', listenEvents, false);
        if (listenEvents) then begin
            CurrPage.D365BCPingPong.SetTimerInterval(500);
            CurrPage.D365BCPingPong.StartTimer();
            filterRecords('~!@!~');
        end;

    end;

    procedure filterRecords(docNo: text)
    begin
        // SWC816 AK 260416 >>
        rec.FILTERGROUP(4);
        rec.SETRANGE("Document No.", DocNo);
        rec.FILTERGROUP(0);
        CurrPage.UPDATE(FALSE);
        // SWC816 AK 260416 <<

    end;

    var
        ism: codeunit "Isolated Storage Management GE";
        listenEvents: Boolean;
}