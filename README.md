# AGY Image Generation Skill

Codex CLIで画像生成を依頼するときに、ローカルの`agy` CLIへ生成処理を委譲するためのスキルです。

## セットアップ

リポジトリを取得したら、利用しているOSに合わせてセットアップスクリプトを実行します。

Linux/macOS:

```sh
bash setup.sh
```

Windows PowerShell:

```powershell
.\setup.ps1
```

既に同じスキルが入っている場合は上書きせずに止まります。更新したい場合は次を使います。

```sh
bash setup.sh --force
```

```powershell
.\setup.ps1 -Force
```

インストール先や`agy` CLIの検出状況だけ確認したい場合:

```sh
bash setup.sh --check
```

```powershell
.\setup.ps1 -Check
```

PowerShellの実行ポリシーで止まる場合は、次のようにその実行だけ許可できます。

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

### 1. スキルを配置する

Codex CLIが読めるskillsディレクトリに、このフォルダを配置します。

標準的には`CODEX_HOME`が設定されていれば次の場所です。

```text
$CODEX_HOME/skills/agy-image-generation
```

`CODEX_HOME`を設定していない場合は、通常はユーザーホーム配下の`.codex/skills`に配置します。

```text
~/.codex/skills/agy-image-generation
```

### 2. `agy` CLIを使える状態にする

`agy` CLIをインストールし、Codex CLIを実行するシェルから`agy`コマンドを呼び出せるようにします。インストール方法は`agy`側の配布元やドキュメントに従ってください。

確認コマンドの例:

```sh
agy --version
agy --help
```

Linux/macOSのシェルでは、次でも確認できます。

```sh
command -v agy
```

PowerShellでは、次でも確認できます。

```powershell
Get-Command agy
```

Windowsでセットアップする場合はPowerShell用スクリプトを使います。

```powershell
.\setup.ps1
```

### 3. Codex CLIで呼び出す

Codex CLIを起動し、`$agy-image-generation`を明示して依頼します。初回利用時、Codexは`agy --help`などを読んで、その環境に入っている`agy` CLIの実際の構文に合わせて実行します。

## 使い方

Codex CLIで次のように呼び出します。

```text
Use $agy-image-generation to generate a cinematic landscape image of a quiet mountain lake at sunrise.
```

日本語でも使えます。

```text
Use $agy-image-generation to generate a 16:9 image of a futuristic Tokyo cafe at night.
```

または、より自然に依頼してもかまいません。

```text
$agy-image-generation で、SNS投稿用の正方形バナー画像を作って。題材は新作コーヒー、雰囲気は落ち着いた高級感。
```

## 前提

- Codex CLIからこのスキルが読める場所に配置されていること
- `agy` CLIがインストール済みで、実行環境の`PATH`から呼び出せること
- Linux、macOS、Windowsのいずれでも利用できるよう、スキル内ではOS固定のパスやシェルを前提にしません

`agy`が見つからない場合、Codexはインストールまたは`PATH`設定が必要だと伝えるだけで、別の画像生成手段へ勝手に切り替えません。

## 生成時の流れ

1. Codexが画像の目的、構図、スタイル、サイズ、枚数、保存先を整理します。
2. `agy --help`などで、その環境に入っている`agy` CLIの実際の使い方を確認します。
3. `agy` CLIで画像を生成します。
4. 出力ファイルが存在し、空でないことを確認します。
5. 生成された画像のパスを返します。

## 出力先

指定がなければ、ワークスペース内の相対パスを使う想定です。

```text
./generated-images/example.png
```

絶対パスが必要な場合は、実行中のOSに合う形式をCodexが使います。

## 例

```text
Use $agy-image-generation to generate 3 square product mockup images for a minimalist perfume bottle, soft studio lighting, neutral background.
```

```text
Use $agy-image-generation to create a transparent-background icon of a small delivery robot, simple friendly 3D style.
```

```text
$agy-image-generation で、前回の画像よりも背景を明るくして、人物を中央に寄せた別案を作って。
```

## 関連ファイル

- `SKILL.md`: Codexが実際に読むスキル本体
- `references/agy-cli-discovery.md`: `agy` CLIのコマンド体系が不明なときの確認メモ
- `agents/openai.yaml`: UI表示用メタデータ
