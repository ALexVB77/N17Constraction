report 50001 "TempStarter"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'TempStarter';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';

                    field("Run Notification Entry Dispatcher"; RunNotificationDispatcher)
                    {
                        ApplicationArea = All;
                        Caption = 'Run Notification Entry Dispatcher';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        WEH: Codeunit "Workflow Event Handling";
        //WEHExt: Codeunit "Workflow Event Handling (Ext)";
        WRPH: Codeunit "Workflow Request Page Handling";
        WRH: Codeunit "Workflow Response Handling";
        WRHExt: Codeunit "Workflow Response Handling Ext";

        WSA: Record "Workflow Step Argument";
    begin

        SelectLatestVersion();

        // Для всех

        WRH.AddResponsePredecessor(WRH.SendApprovalRequestForApprovalCode(), WEH.RunWorkflowOnRejectApprovalRequestCode());

        // Акты и заявки

        WRH.AddResponseToLibrary(
            WRHExt.CreateApprovalRequestsActCode(),
            0,
            'Создать запрос утверждения для Акта, КС-2 и Заявки на оплату', 'GROUP 10');
        WRH.AddResponsePredecessor(WRHExt.CreateApprovalRequestsActCode(), WEH.RunWorkflowOnSendPurchaseDocForApprovalCode());

        WRH.AddResponseToLibrary(
            WRHExt.MoveToNextActStatusCode(),
            0,
            'Перейти к следующему статусу утверждения Акта, КС-2 и Заявки на оплату', 'GROUP 10');
        WRH.AddResponsePredecessor(WRHExt.MoveToNextActStatusCode(), WEH.RunWorkflowOnApproveApprovalRequestCode());

        WRH.AddResponseToLibrary(
            WRHExt.MoveToPrevActStatusCode(),
            0,
            'Вернуться к предыдущему статусу утверждения Акта, КС-2 и Заявки на оплату', 'GROUP 10');
        WRH.AddResponsePredecessor(WRHExt.MoveToPrevActStatusCode(), WEH.RunWorkflowOnRejectApprovalRequestCode());

        WRH.AddResponseToLibrary(
            WRHExt.DelegateApprovalRequestsActCode(),
            0,
            'Делегировать Акт, КС-2 и Заявку на оплату новому утверждающему', 'GROUP 10');
        WRH.AddResponsePredecessor(WRHExt.DelegateApprovalRequestsActCode(), WEH.RunWorkflowOnDelegateApprovalRequestCode());

        WRH.AddResponseToLibrary(
            WRHExt.CancelApprovalRequestsActCode(),
            0,
            'Отменить запрос утверждения для Акта, КС-2 и Заявки на оплату и создать уведомление.', 'GROUP 10');
        WRH.AddResponsePredecessor(WRHExt.CancelApprovalRequestsActCode(), WEH.RunWorkflowOnCancelPurchaseApprovalRequestCode());


        // WSA.SetFilter("Response Function Name", '%1|%2|%3|%4',
        //     WRHExt.CreateApprovalRequestsActCode(), WRHExt.MoveToNextActStatusCode(),  WRHExt.MoveToPrevActStatusCode(),     

        if RunNotificationDispatcher then
            Codeunit.Run(CODEUNIT::"Notification Entry Dispatcher");

    end;

    var
        RunNotificationDispatcher: Boolean;

}

