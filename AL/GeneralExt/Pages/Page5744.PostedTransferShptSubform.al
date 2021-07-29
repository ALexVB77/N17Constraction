pageextension 85744 "Posted Trans. Shpt. Sub. (Ext)" extends "Posted Transfer Shpt. Subform"
{
    // NC 51410 > EP
    // В стандарте есть поля для шорткатов, а код для загрузки значений в них добавить забыли...
    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;
    // NC 51410 < EP
}