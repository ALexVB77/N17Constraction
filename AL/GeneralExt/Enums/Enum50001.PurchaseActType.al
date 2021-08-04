enum 50001 "Purchase Act Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ''; }
    value(1; "Act") { Caption = 'Act'; }
    value(2; "KC-2") { Caption = 'KC-2'; }
    // value(3; "Act (Production)") { Caption = 'Act (Production)'; }       // этот тип больше не используется
    // value(4; "KC-2 (Production)") { Caption = 'KC-2 (Production)'; }     // этот тип больше не используется
    value(5; "Advance") { Caption = 'Advance'; }
}