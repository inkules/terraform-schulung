# Module und Outputs

Bisher lag der gesamte Code in einem einzigen Ordner - dem sogenannten Root-Modul. Terraform erlaubt es aber, Konfiguration in wiederverwendbare Bausteine aufzuteilen: **Module**. In diesem Kapitel baut ihr ein eigenes Modul, das etwas Sichtbares und tatsächlich Nützliches erzeugt: eine kleine, im Browser anschaubare HTML-Seite. Dabei kommen zwei neue Werkzeuge dazu, die in realen Modulen ständig gebraucht werden: Template-Dateien und strukturierte Variablentypen.

## Was ist ein Modul?

Technisch gesehen ist jeder Ordner mit `.tf`-Dateien bereits ein Modul. Der Ordner, in dem `terraform apply` ausgeführt wird, heißt **Root-Modul**. Jeder weitere Ordner, der über einen `module`-Block eingebunden wird, ist ein **Child-Modul**:

```hcl
module "seite" {
  source = "./modules/webseite"

  titel = "Terraform-Schulung"
}
```

`source` zeigt dabei auf den Ordner mit der Modul-Konfiguration - hier lokal, es kann aber genauso ein Git-Repository oder die Terraform Registry sein. Alles, was das Modul von außen benötigt, muss explizit als Variable hineingereicht werden. Ein Modul hat keinen Zugriff auf Variablen oder Ressourcen aus dem Root-Modul, außer denen, die ihm über `module`-Argumente übergeben werden.

Ein Modul lohnt sich immer dann, wenn dieselbe Logik mehrfach gebraucht wird - im eigenen Projekt (siehe [Module implementieren](../../02-module-und-deployment/06-module-implementieren/00-module-implementieren.md)) oder sogar über mehrere Projekte und Teams hinweg. Ein gutes Modul hat eine klare Aufgabe, sinnvolle Variablen mit Beschreibungen, und gibt über Outputs zurück, was Aufrufer davon brauchen könnten.

## Outputs: Werte aus einem Modul herausreichen

Genauso wie ein Modul nur über Variablen Werte empfängt, gibt es Werte nur über `output`-Blöcke zurück. Im Root-Modul greift man darauf über `module.<name>.<output_name>` zu:

```hcl
output "seite_pfad" {
  value = module.seite.pfad
}
```

Module sind also bewusst wie eine Blackbox aufgebaut: Variablen rein, Outputs raus. Das macht sie testbar und wiederverwendbar, unabhängig davon, wie sie intern aufgebaut sind.

## Neu: templatefile()

Bisher wurde der Inhalt von Dateien direkt als String in `.tf`-Dateien geschrieben, per String-Interpolation zusammengesetzt (siehe [HCL](../02-hcl/00-hcl.md)). Das wird schnell unübersichtlich, sobald der Inhalt mehr als ein, zwei Zeilen hat - z.B. bei einer ganzen HTML-Seite. Die Funktion `templatefile(pfad, variablen)` liest stattdessen eine separate Template-Datei ein und ersetzt darin Platzhalter:

```hcl
content = templatefile("${path.module}/templates/index.html.tftpl", {
  titel = var.titel
})
```

In der Template-Datei (Endung `.tftpl`) funktioniert dieselbe `${...}`-Interpolation wie in normalem HCL, zusätzlich gibt es `%{ for ... }`/`%{ endfor }` für Schleifen innerhalb des Templates:

```text
<ul>
%{ for link in links }
  <li><a href="${link.url}">${link.label}</a></li>
%{ endfor }
</ul>
```

Das trennt sauber: HCL kümmert sich um Logik und Werte, die Template-Datei um die eigentliche Struktur des Ergebnisses (hier: HTML).

## Neu: object-Typen

Die Liste von Links im Beispiel braucht mehr Struktur als ein einfaches `list(string)` - jeder Link hat sowohl eine Beschriftung als auch eine URL. Dafür gibt es `object(...)`, mit dem sich eigene, benannte Strukturen als Variablentyp definieren lassen:

```hcl
variable "links" {
  type = list(object({
    label = string
    url   = string
  }))
  default = []
}
```

Ein Wert dafür sieht dann so aus:

```hcl
links = [
  { label = "Terraform Docs", url = "https://developer.hashicorp.com/terraform" },
]
```

## Aufbau des Moduls

Das Modul `webseite` (siehe unten im Ordner `modules/webseite/`) generiert eine kleine HTML-Seite:

- **`variables.tf`**: `titel` (Pflicht), `tagline`, `farbe` (mit Default) und `links` (Liste von Objekten) sowie `output_dir`.
- **`templates/index.html.tftpl`**: die eigentliche HTML-Struktur mit Platzhaltern.
- **`main.tf`**: eine einzige `local_file`-Ressource, deren Inhalt über `templatefile()` aus Variablen und Template zusammengesetzt wird.
- **`outputs.tf`**: gibt den Pfad zur erzeugten Datei zurück.

Aufgerufen wird es wie jedes andere Modul:

```hcl
module "seite" {
  source = "./modules/webseite"

  titel   = "Terraform-Schulung"
  tagline = "Von den Grundlagen bis zur eigenen Cloud-App"
  farbe   = "#5c3aa5"
  links = [
    { label = "Terraform Docs", url = "https://developer.hashicorp.com/terraform" },
    { label = "Terraform Registry", url = "https://registry.terraform.io" },
  ]
  output_dir = "${path.module}/output"
}
```

Ein Modul lässt sich beliebig oft aufrufen, jedes Mal mit einem eigenen Namen und eigenen Werten. Im Beispielordner steckt deshalb noch ein zweiter Aufruf desselben Moduls, `module "seite2"`, mit anderer Farbe und eigenem `output_dir`:

```hcl
module "seite2" {
  source = "./modules/webseite"

  titel   = "Terraform-Schulung"
  tagline = "Von den Grundlagen bis zur eigenen Cloud-App"
  farbe   = "#95b683"
  links = [
    { label = "Terraform Docs", url = "https://developer.hashicorp.com/terraform" },
    { label = "Terraform Registry", url = "https://registry.terraform.io" },
  ]
  output_dir = "${path.module}/output2"
}
```

`seite` und `seite2` sind dabei komplett unabhängige Instanzen desselben Moduls - jede bekommt ihren eigenen Eintrag im State und erzeugt ihre eigene HTML-Datei. Wer mehr als zwei Instanzen braucht, die sich zudem in einer Liste oder Map beschreiben lassen, greift statt vieler einzelner `module`-Blöcke besser zu `for_each` auf dem `module`-Block - genau das Thema von [Module implementieren](../../02-module-und-deployment/06-module-implementieren/00-module-implementieren.md).

## Ein drittes Modul: dasselbe Prinzip, anderer Inhalt

`templatefile()` ist nicht auf schlichtes HTML beschränkt - das Template kann genauso gut CSS und JavaScript enthalten. Das Modul `raetsel` (siehe `modules/raetsel/`) nutzt genau dasselbe Muster wie `webseite` (Variablen rein, `templatefile()` erzeugt eine `local_file`), erzeugt aber eine kleine, interaktive Quiz-Seite mit 15 Fragen zum heutigen Stoff:

```hcl
module "tag1_raetsel" {
  source = "./modules/raetsel"

  titel       = "Tag-1-Check: Terraform-Grundlagen"
  farbe       = "#5c3aa5"
  output_pfad = "${path.module}/output/raetsel.html"
}
```

Anders als bei `webseite` kommen die Fragen dabei bewusst **nicht** als Terraform-Variable rein, sondern stehen direkt als JavaScript-Array im Template `modules/raetsel/templates/raetsel.html.tftpl` - das Modul-Interface bleibt dadurch genauso schlicht wie bei `webseite` (nur `titel`, `farbe`, `output_pfad`), und die Fragen lassen sich bearbeiten, ohne irgendetwas an der `.tf`-Konfiguration anzufassen.

⚠️ Eine Falle beim Schreiben von JS in einem `.tftpl`-Template: JavaScript-Template-Literale (`` `Text ${variable}` ``) kollidieren mit Terraforms eigener `${...}`-Interpolation. Terraform versucht `${variable}` als HCL-Ausdruck zu parsen und bricht mit `Invalid expression; Expected the start of an expression` ab. Im mitgelieferten Template wird das über normale String-Konkatenation (`"Text " + variable`) umgangen statt über Template-Literale.

## Module und State

Ressourcen aus einem Child-Modul tauchen im State mit einem vorangestellten Pfad auf, z.B. `module.seite.local_file.seite` statt einfach `local_file.seite`. So bleibt auch im State erkennbar, aus welchem Modul eine Ressource stammt.

## Selbst ausprobieren

In diesem Ordner liegt das komplette Beispiel mit dem `local`-Provider (kein Cloud-Zugang nötig):

```bash
terraform init
terraform apply
terraform output
terraform state list
```

Beim `terraform state list` ist gut zu erkennen, dass es zwei getrennte Einträge gibt - `module.seite.local_file.seite` und `module.seite2.local_file.seite` - statt einfach `local_file.seite` zu heißen.

Der Clou an diesem Beispiel: Das Ergebnis lässt sich tatsächlich anschauen. Nach dem `apply` liegen unter `output/index.html` und `output2/index.html` zwei fertige, im Browser öffenbare Seiten in unterschiedlichen Farben - einfach die Dateien doppelklicken oder mit `xdg-open output/index.html` (Linux) bzw. `open output/index.html` (macOS) öffnen. Zusätzlich liegt unter `output/raetsel.html` das Tag-1-Quiz aus dem dritten Modul - ebenfalls einfach im Browser öffnen und durchklicken.

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 4](../../playground/04-eigenes-modul/AUFGABE.md).

Zum Ausprobieren lohnt es sich, in `main.tf` `farbe` zu ändern oder einen weiteren Eintrag zu `links` hinzuzufügen und den `apply` erneut laufen zu lassen - die Änderung taucht sofort in der generierten Seite auf.

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 4](../../playground/04-eigenes-modul/AUFGABE.md).
