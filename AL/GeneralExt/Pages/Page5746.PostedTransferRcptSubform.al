pageextension 85746 "Posted Trans. Rcpt. Sub. (Ext)" extends "Posted Transfer Rcpt. Subform"
{
    // NC 51410 > EP
    // В стандарте есть поля для шорткатов, а код для загрузки значений в них добавить забыли...
    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;
    // NC 51410 < EP
}