pageextension 80141 "Posted Purch. Cr. Memo Sub. GE" extends "Posted Purch. Cr. Memo Subform"
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
                    corr: Boolean;
                begin
                    currpage.D365BCPingPong.StopTimer();
                    if ism.getBool('p50031_Corr', corr, false) then begin
                        if corr then begin
                            ism.delValue('p50031_Corr');
                            ism.getString('p50031_DocNo', docNo, true);
                            filterRecords(docNo);
                        end;
                        CurrPage.D365BCPingPong.StartTimer();
                    end;
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
