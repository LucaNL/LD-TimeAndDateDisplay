-- Messages for /clock. Day and month names come from the game's browser, in any language (Config.Locale).
Locales = {
    en = { hidden = 'Clock hidden. Type /%s to show it again.', shown = 'Clock shown.' },
    nl = { hidden = 'Klok verborgen. Typ /%s om hem weer te tonen.', shown = 'Klok zichtbaar.' },
    de = { hidden = 'Uhr ausgeblendet. Tippe /%s, um sie wieder anzuzeigen.', shown = 'Uhr eingeblendet.' },
    fr = { hidden = 'Horloge masquée. Tape /%s pour la réafficher.', shown = 'Horloge affichée.' },
    es = { hidden = 'Reloj oculto. Escribe /%s para mostrarlo de nuevo.', shown = 'Reloj visible.' },
    pt = { hidden = 'Relógio oculto. Digite /%s para mostrar de novo.', shown = 'Relógio visível.' },
    pl = { hidden = 'Zegar ukryty. Wpisz /%s, aby go pokazać.', shown = 'Zegar widoczny.' },
    tr = { hidden = 'Saat gizlendi. Tekrar göstermek için /%s yaz.', shown = 'Saat gösteriliyor.' },
}

--- Message in the configured language (pt-BR -> pt, unknown -> en).
function LDTDText(key, ...)
    local code = tostring(Config.Locale or 'en'):lower()
    local lang = Locales[code] or Locales[code:sub(1, 2)] or Locales.en
    local str = lang[key] or Locales.en[key] or key
    local ok, res = pcall(string.format, str, ...)
    return ok and res or str
end
