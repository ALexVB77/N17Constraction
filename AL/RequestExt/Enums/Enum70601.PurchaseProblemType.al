enum 70601 "Purchase Problem Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ''; }
    value(1; "Mistake") { Caption = 'Mistake in the document'; }
    value(2; "AgrMiss") { Caption = 'Agreement missing'; }
    value(3; "RController") { Caption = 'Rejected by Contoller'; }
    value(4; "RChecker") { Caption = 'Rejected by Checker'; }
    value(5; "RApprover") { Caption = 'Rejected by Approver'; }
    value(6; "REstimator") { Caption = 'Rejected by Estimator'; }
    value(7; "Act error") { Caption = 'Act error'; }
}