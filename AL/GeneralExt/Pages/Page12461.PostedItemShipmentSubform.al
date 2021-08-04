pageextension 92461 "Posted Item Shipment Sub. GE" extends "Posted Item Shipment Subform"
{
    layout
    {
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
                begin
                    currpage.D365BCPingPong.StopTimer();
                    ism.getString('p50029_DocNo', docNo, true);
                    if (docno <> '') then begin

                        // SWC816 AK 260416 >>
                        rec.FILTERGROUP(4);
                        rec.SETRANGE("Document No.", DocNo);
                        rec.FILTERGROUP(0);
                        CurrPage.UPDATE(FALSE);
                        // SWC816 AK 260416 <<

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
        end;

    end;

    var
        ism: codeunit "Isolated Storage Management GE";
        listenEvents: Boolean;

}
