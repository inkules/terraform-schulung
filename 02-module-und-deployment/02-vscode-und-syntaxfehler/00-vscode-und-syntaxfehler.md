# VS Code und Syntaxfehler

Terraform-Code lässt sich zwar in jedem Texteditor schreiben, aber VS Code mit der offiziellen "HashiCorp Terraform"-Erweiterung macht das Arbeiten deutlich angenehmer: Syntax-Highlighting, Autovervollständigung für Attribute, Inline-Fehleranzeige und automatische Formatierung. Dieses Kapitel zeigt, wie man das sinnvoll nutzt - und was zu tun ist, wenn die Anzeige in der IDE mal nicht mit der Realität übereinstimmt.

## Die Erweiterung einrichten

In VS Code die Erweiterung **HashiCorp Terraform** installieren. Sie bringt einen eigenen Sprachserver (`terraform-ls`) mit, der im Hintergrund läuft und für Autovervollständigung, Hover-Informationen und Diagnosen zuständig ist.

Empfehlenswert ist außerdem, Formatierung beim Speichern zu aktivieren, in den VS Code-Einstellungen (`settings.json`):

```json
{
  "[terraform]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "hashicorp.terraform"
  },
  "[terraform-vars]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "hashicorp.terraform"
  }
}
```

Damit wird beim Speichern automatisch `terraform fmt` auf die aktuelle Datei angewendet.

## terraform fmt: einheitliche Formatierung

`terraform fmt` formatiert HCL-Dateien nach einem festen Stil - konsistente Einrückung, ausgerichtete `=`-Zeichen, keine überflüssigen Leerzeilen. Das ist rein kosmetisch und ändert nichts am Verhalten der Konfiguration, macht Diffs in Git aber deutlich lesbarer, wenn alle im Team denselben Stil verwenden.

Aus einer unformatierten Datei wie dieser:

```hcl
resource "local_file" "messy" {
      filename = "${path.module}/messy.txt"
  content =    var.content
  }
```

macht `terraform fmt` automatisch:

```hcl
resource "local_file" "messy" {
  filename = "${path.module}/messy.txt"
  content  = var.content
}
```

Mit `terraform fmt -check -diff` lässt sich das auch anzeigen, ohne die Datei tatsächlich zu ändern - praktisch für eine CI-Pipeline, die prüfen soll, ob jemand vergessen hat zu formatieren.

## Wenn VS Code einen Fehler anzeigt, den es nicht gibt

Gelegentlich zeigt VS Code eine rote Markierung an einer Stelle, obwohl `terraform validate` auf der Kommandozeile keinen Fehler findet. Das liegt daran, dass `terraform-ls` sich beim Öffnen eines Ordners einen Index aus Modul-Schemas und Provider-Informationen aufbaut und diesen zwischenspeichert. Wird eine Datei außerhalb des aktuellen Editor-Fensters geändert - z.B. von einem anderen Tool, einem Git-Pull oder einem zweiten Editor-Fenster - bekommt der Sprachserver das nicht immer sofort mit, besonders bei Änderungen, die sich auf ein anderes File auswirken (z.B. eine neue Variable in einem Kindmodul).

Typische Symptome:

- Eine gerade erst hinzugefügte Variable wird als "not expected here" markiert, obwohl sie existiert.
- Ein Modul-Argument wird als unbekannt angezeigt, obwohl `terraform validate` durchläuft.

Der zuverlässigste Fix in diesem Fall:

1. Die betroffene Datei einmal aktiv bearbeiten und speichern, um ein Neu-Parsen anzustoßen.
2. Falls das nicht hilft: Command Palette (`Strg`/`Cmd` + `Shift` + `P`) → **"Developer: Reload Window"**. Das startet den Sprachserver-Prozess neu und baut den Index frisch auf.

Im Zweifel gilt immer: `terraform validate` auf der Kommandozeile ist die Wahrheit, die IDE-Anzeige ist nur ein (meist sehr gutes, aber gelegentlich verzögertes) Hilfsmittel.

## Der umgekehrte Fall

Genauso kann es passieren, dass VS Code keinen Fehler anzeigt, `terraform apply` aber trotzdem fehlschlägt. Der Sprachserver prüft nämlich nur Syntax, Referenzen und die Attribut-Schemas der Provider - nicht aber providerseitige Geschäftsregeln, die erst zur Laufzeit ausgewertet werden (z.B. "dieser Ressourcenname ist global bereits vergeben"). Solche Fehler sieht man wirklich erst beim `apply` - siehe dazu das vorherige Kapitel [Troubleshooting](../01-troubleshooting/00-troubleshooting.md).

## Selbst ausprobieren

In diesem Ordner liegt absichtlich schlecht formatierter, aber gültiger Code (`local`-Provider, kein Cloud-Zugang nötig):

```bash
terraform init
terraform validate           # läuft trotz schlechter Formatierung durch
terraform fmt -check -diff   # zeigt, was fmt ändern würde
terraform fmt                # formatiert die Dateien tatsächlich
```

Wer die Dateien stattdessen in VS Code öffnet und dort einmal speichert (bei aktiviertem `formatOnSave`), sieht denselben Effekt direkt im Editor.
