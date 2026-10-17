#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

ConfigPath := A_ScriptDir . "\nya-hotkey.ini"

if !FileExist(ConfigPath) {
    IniWrite("Insert", ConfigPath, "Hotkeys", "Encode")
    IniWrite("ScrollLock", ConfigPath, "Hotkeys", "Decode")
    IniWrite("https://nya-api.keitodaze.net", ConfigPath, "API", "Base")
    IniWrite("1", ConfigPath, "Mouse", "DecodeOnSelect")
    IniWrite("6000", ConfigPath, "Mouse", "DisplayMs")
}

ApiBase := IniRead(ConfigPath, "API", "Base", "https://nya-api.keitodaze.net")
EncodeKey := IniRead(ConfigPath, "Hotkeys", "Encode", "Insert")
DecodeKey := IniRead(ConfigPath, "Hotkeys", "Decode", "ScrollLock")

try {
    Hotkey(EncodeKey, Convert.Bind("encode"))
    Hotkey(DecodeKey, Convert.Bind("decode"))
} catch as e {
    MsgBox("nya-hotkey.ini のキー指定が不正です: " . e.Message, "nya-hotkey", "Iconx")
    ExitApp()
}

MouseDecodeEnabled := IniRead(ConfigPath, "Mouse", "DecodeOnSelect", "1") = "1"
MouseDecodeMs := Integer(IniRead(ConfigPath, "Mouse", "DisplayMs", "6000"))
LDownX := 0
LDownY := 0

if MouseDecodeEnabled {
    ~LButton::RecordDown()
    ~LButton Up::CheckDrag()
}

RecordDown() {
    global LDownX, LDownY
    MouseGetPos(&LDownX, &LDownY)
}

CheckDrag() {
    global LDownX, LDownY
    MouseGetPos(&x, &y)
    if (Abs(x - LDownX) > 8 || Abs(y - LDownY) > 8)
        DecodeSelection()
}

DecodeSelection() {
    savedClip := ClipboardAll()
    copied := false
    loop 2 {
        A_Clipboard := ""
        Send("^c")
        if ClipWait(0.8) {
            copied := true
            break
        }
        Sleep(80)
    }
    text := A_Clipboard
    A_Clipboard := savedClip
    if !copied || StrLen(Trim(text)) < 2
        return

    try {
        result := CallDecode(text)
    } catch {
        return
    }

    global MouseDecodeMs
    MouseGetPos(&mx, &my)
    ToolTip(result, mx + 12, my + 12)
    SetTimer(() => ToolTip(), -MouseDecodeMs)
}

Convert(mode, ThisHotkey := "") {
    savedClip := ClipboardAll()

    copied := false
    loop 2 {
        A_Clipboard := ""
        Send("^a")
        Sleep(80)
        Send("^c")
        if ClipWait(1.5) {
            copied := true
            break
        }
        Sleep(100)
    }
    if !copied {
        Flash("コピーできませんでした")
        A_Clipboard := savedClip
        return
    }

    text := A_Clipboard
    if (text = "") {
        A_Clipboard := savedClip
        return
    }

    try {
        result := (mode = "encode") ? CallEncode(text) : CallDecode(text)
    } catch as e {
        Flash("通信エラー: " . e.Message)
        A_Clipboard := savedClip
        return
    }

    A_Clipboard := result
    Send("^v")
    Sleep(150)
    A_Clipboard := savedClip
    Flash(mode = "encode" ? "にゃ語に変換しました" : "日本語に戻しました")
}

CallEncode(text) {
    body := '{"text":' . JsonStr(text) . '}'
    return ExtractField(PostJson(ApiBase . "/v1/encode", body), "text")
}

CallDecode(text) {
    body := '{"nya":' . JsonStr(text) . '}'
    return ExtractField(PostJson(ApiBase . "/v1/decode", body), "text")
}

PostJson(url, body) {
    stream := ComObject("ADODB.Stream")
    stream.Type := 2
    stream.Charset := "utf-8"
    stream.Open()
    stream.WriteText(body)
    stream.Position := 0
    stream.Type := 1
    stream.Position := 3
    data := stream.Read()

    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, false)
    whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
    whr.Send(data)

    if (whr.Status != 200)
        throw Error("HTTP " . whr.Status . ": " . whr.ResponseText)
    return whr.ResponseText
}

JsonStr(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`r`n", "\n")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", "\t")
    return '"' . s . '"'
}

ExtractField(json, field) {
    if !RegExMatch(json, '"' . field . '":"((?:[^"\\]|\\.)*)"', &m)
        throw Error("レスポンスを解析できませんでした: " . json)
    return JsonUnescape(m[1])
}

JsonUnescape(s) {
    out := ""
    i := 1
    len := StrLen(s)
    while (i <= len) {
        c := SubStr(s, i, 1)
        if (c = "\") {
            nc := SubStr(s, i + 1, 1)
            switch nc {
                case "n": out .= "`n"
                case "t": out .= "`t"
                case "r": out .= "`r"
                case '"': out .= '"'
                case "\": out .= "\"
                case "/": out .= "/"
                default: out .= nc
            }
            i += 2
        } else {
            out .= c
            i += 1
        }
    }
    return out
}

Flash(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -1500)
}
