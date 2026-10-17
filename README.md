# nya-hotkey

猫語翻訳を楽にしたAutoHotkeyスクリプト。ワンキーで日本語⇔にゃ語を相互変換します。
どのアプリの上でも(Discord、ブラウザ、メモ帳…)、選択なしでそのまま使えます。

## 動作の仕組み

ホットキーを押すと:

1. 今フォーカスしているフィールドの中身を全選択してコピー
2. APIに送信して変換
3. 結果をそのまま貼り付けて置き換える

マウスでテキストをドラッグ選択したときは、置き換えずに**その場ににゃ語→日本語の訳をツールチップ表示**します(読むだけで、選択中の内容は変えません)。

## 必要なもの

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/) (v2.0以降)

## セットアップ

1. AutoHotkey v2をインストール
   ```
   winget install AutoHotkey.AutoHotkey
   ```
2. `nya-hotkey.ahk` をダブルクリックして起動
   (初回起動時に `nya-hotkey.ini` が自動生成されます)

常駐起動したい場合は、`nya-hotkey.ahk` のショートカットを
`shell:startup` (Win+R で開けるフォルダ) に置いてください。

## 既定のホットキー

| キー | 動作 |
|---|---|
| `Insert` | 日本語 → にゃ語 |
| `ScrollLock` | にゃ語 → 日本語 |

## 設定 (`nya-hotkey.ini`)

同じフォルダの `nya-hotkey.ini` を編集すると、キーやAPIの向き先を変更できます。

```ini
[Hotkeys]
Encode=Insert
Decode=ScrollLock

[API]
Base=https://nya-api.keitodaze.net

[Mouse]
DecodeOnSelect=1
DisplayMs=6000
```

`DecodeOnSelect=0` にすると、マウスドラッグでの自動翻訳表示を無効にできます。
`DisplayMs` はツールチップの表示時間(ミリ秒)です。

使えるキー名は [AutoHotkeyのKeyList](https://www.autohotkey.com/docs/v2/KeyList.htm) を参照してください。
`XButton1` / `XButton2` (マウスのサイドボタン) や `^!n` (Ctrl+Alt+N) のような組み合わせも指定できます。

設定を変更したら、タスクトレイのアイコンを右クリック→ **Reload Script** で反映されます。

## ライセンス

MIT
