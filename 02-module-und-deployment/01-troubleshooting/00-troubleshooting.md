# Troubleshooting

Terraform-Fehlermeldungen wirken am Anfang oft kryptisch, folgen aber tatsächlich einem klaren Muster. Wer weiß, auf welcher der drei Ebenen ein Fehler auftritt, findet die Ursache meist in wenigen Sekunden. Dieses Kapitel geht die häufigsten Fehlerklassen an echten, kaputten Beispielen durch, die ihr selbst reparieren müsst.

## Die drei Ebenen, auf denen Fehler auftreten

1. **Parsing (Syntax)**: Terraform kann die `.tf`-Datei gar nicht erst als gültiges HCL einlesen. Betrifft sogar schon `terraform init`, denn ohne gültige Syntax weiß Terraform nicht einmal, welche Provider es braucht.
2. **Validierung (Referenzen & Typen)**: Die Datei ist syntaktisch korrekt, aber referenziert z.B. eine nicht existierende Variable oder verwendet ein Attribut, das die Ressource gar nicht kennt. Wird von `terraform validate` gefunden.
3. **Planning/Apply (Werte & Provider)**: Die Konfiguration ist strukturell gültig, aber es fehlt ein Wert, es gibt eine zirkuläre Abhängigkeit, oder der Provider lehnt die eigentliche Änderung ab. Wird erst bei `terraform plan` oder `terraform apply` sichtbar - `validate` allein reicht hier nicht.

Der wichtigste Kniff dabei: Ebene 1 und 2 kosten nichts und brauchen keine echte Infrastruktur. `terraform validate` im Zweifel immer zuerst laufen lassen.

## Selbst ausprobieren: acht kaputte Konfigurationen

In diesem Ordner liegen acht Unterordner `uebung-1-syntax/` bis `uebung-8-netzwerk/`. Jeder enthält eine absichtlich kaputte, aber in sich abgeschlossene Konfiguration - die ersten sechs mit dem `local`-Provider, die letzten beiden zusätzlich mit `http` (beides ohne Cloud-Zugang nutzbar). Für jede Übung gilt derselbe Ablauf:

```bash
cd uebung-<nummer>-<name>
terraform init
terraform validate
```

Ziel ist es, die Fehlermeldung zu lesen, die Ursache in der jeweiligen `.tf`-Datei zu finden und zu beheben, bis `terraform validate` (bzw. `terraform apply`) durchläuft. Die folgenden Abschnitte zeigen, was jeweils kaputt ist und welche Fehlermeldung dabei herauskommt - als Kontrolle, falls ihr nicht weiterkommt.

### Übung 1: Syntax-Fehler

`uebung-1-syntax/main.tf` fehlt ein `=`:

```hcl
resource "local_file" "status" {
  filename "${path.module}/status.txt"
  content  = "Hallo!"
}
```

Hier scheitert schon `terraform init`, nicht erst `validate` - ohne gültige Syntax kann Terraform nicht einmal ermitteln, welche Provider gebraucht werden:

```text
Error: Invalid string literal

  on main.tf line 3, in resource "local_file" "status":
   3:   filename "${path.module}/status.txt"

Template sequences are not allowed in this string. To include a literal "$",
double it (as "$$") to escape it.

Error: Invalid block definition

  on main.tf line 3, in resource "local_file" "status":
   3:   filename "${path.module}/status.txt"
   4:   content  = "Hallo!"

A block definition must have block content delimited by "{" and "}", starting
on the same line as the block header.
```

**Fix:** das fehlende `=` nach `filename` ergänzen.

### Übung 2: Referenz auf eine undeklarierte Variable

`uebung-2-referenz/variables.tf` deklariert `content`, aber `main.tf` verwendet `var.message`:

```text
Error: Reference to undeclared input variable

  on main.tf line 4, in resource "local_file" "status":
   4:   content  = var.message

An input variable with the name "message" has not been declared. This
variable can be declared with a variable "message" {} block.
```

**Fix:** in `main.tf` `var.message` zu `var.content` korrigieren (Tippfehler-Klassiker).

### Übung 3: Unbekanntes Attribut

`uebung-3-attribut/main.tf` verwendet `text` statt `content`:

```text
Error: Unsupported argument

  on main.tf line 4, in resource "local_file" "status":
   4:   text     = "Hallo!"

An argument named "text" is not expected here.
```

**Fix:** `text` zu `content` umbenennen. Jede Ressource hat eine feste, vom Provider vorgegebene Liste erlaubter Attribute - ein Blick in die [Provider-Dokumentation](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) hilft, wenn der richtige Name nicht offensichtlich ist.

### Übung 4: Fehlende Pflichtvariable

`uebung-4-pflichtvariable/variables.tf` deklariert `content` ohne `default`, und es gibt weder eine `terraform.tfvars` noch ein `-var`. Hier reicht `terraform validate` nicht aus, um den Fehler zu sehen - er zeigt sich erst bei `terraform plan`:

```bash
terraform validate   # meldet "Success!" - Struktur ist ja korrekt
terraform plan        # erst hier kommt der eigentliche Fehler
```

```text
Error: No value for required variable

  on variables.tf line 2:
   2: variable "content" {

The root module input variable "content" is not set, and has no default
value. Use a -var or -var-file command line argument to provide a value for
this variable.
```

**Fix:** entweder einen `default`-Wert ergänzen, oder beim Ausführen `-var="content=Hallo!"` übergeben. Diese Übung zeigt gut, warum `validate` allein nicht genügt - es prüft nur die Struktur, nicht ob am Ende alle Werte tatsächlich vorhanden sind.

### Übung 5: Zirkuläre Abhängigkeit

`uebung-5-zirkel/main.tf` lässt zwei `locals` sich gegenseitig referenzieren:

```hcl
locals {
  a = local.b
  b = local.a
}
```

```text
Error: Cycle: local.b (expand), local.a (expand)
```

**Fix:** die zirkuläre Referenz auflösen, z.B. indem `b` einen festen Wert bekommt statt auf `a` zu verweisen. Terraform baut aus allen Ressourcen, Variablen und `locals` einen Abhängigkeitsgraphen, um die richtige Reihenfolge zu bestimmen - ein Zyklus in diesem Graphen kann grundsätzlich nicht aufgelöst werden.

### Übung 6: Typkonflikt bei einer Variable

`uebung-6-typkonflikt/variables.tf` deklariert `type = number`, der `default`-Wert ist aber ein String:

```hcl
variable "anzahl" {
  type    = number
  default = "drei"
}
```

```text
Error: Invalid default value for variable

  on variables.tf line 5, in variable "anzahl":
   5:   default     = "drei"

This default value is not compatible with the variable's type constraint: a
number is required.
```

**Fix:** `"drei"` durch eine echte Zahl ersetzen, z.B. `3`. Terraform prüft `default`-Werte gegen den deklarierten `type` - das verhindert, dass falsche Werte erst tief in einer Ressource zu einem unklaren Folgefehler führen.

Die bisherigen sechs Übungen scheitern alle, bevor irgendetwas auf der Festplatte oder im Netzwerk passiert - `validate` oder `plan` reichen aus, um sie zu finden. Die nächsten beiden Übungen sind anders: Sie sind syntaktisch und strukturell völlig in Ordnung. Der Fehler zeigt sich erst, wenn Terraform tatsächlich etwas *tut*.

### Übung 7: Fehler beim Apply - Dateisystem-Berechtigung

`uebung-7-dateirechte/main.tf` lässt Terraform ein Verzeichnis mit `directory_permission = "0555"` anlegen (les- und ausführbar, aber nicht beschreibbar) und will dann eine Datei hineinschreiben:

```hcl
resource "local_file" "status" {
  filename             = "${path.module}/gesperrt/status.txt"
  content              = "Hallo!"
  directory_permission = "0555"
}
```

`terraform validate` und `terraform plan` sehen hier kein Problem - beide fassen die Festplatte nicht an, sie berechnen nur, was passieren *würde*:

```bash
terraform validate   # Success!
terraform plan        # Plan: 1 to add, 0 to change, 0 to destroy.
terraform apply        # erst hier kommt der eigentliche Fehler
```

```text
Error: Create local file error

  with local_file.status,
  on main.tf line 5, in resource "local_file" "status":
   5: resource "local_file" "status" {

An unexpected error occurred while writing the file

Original Error: open ./gesperrt/status.txt: permission denied
```

**Fix:** `directory_permission` auf einen Wert setzen, der Schreibzugriff erlaubt (z.B. `"0755"`). Diese Übung ist das lokale Äquivalent zu vielen Cloud-Fehlern: Die Konfiguration ist korrekt, aber die Umgebung (hier: Dateisystemrechte, dort: Cloud-Berechtigungen) lässt die Aktion nicht zu. Als Aufräumschritt danach das erzeugte `gesperrt/`-Verzeichnis löschen (`rm -rf gesperrt`), sonst lässt es sich beim nächsten Versuch nicht überschreiben.

### Übung 8: Fehler beim Plan - Netzwerk/API

`uebung-8-netzwerk/main.tf` fragt über den `http`-Provider eine Data Source ab (siehe [Datenquellen](../../01-grundlagen/09-datenquellen/00-datenquellen.md)), deren Domain nicht existiert:

```hcl
data "http" "status" {
  url = "https://diese-domain-existiert-hoffentlich-nicht-xyz123abc.invalid/status"
}
```

```text
Error: Error making request

  with data.http.status,
  on main.tf line 5, in data "http" "status":
   5: data "http" "status" {

Error making request: GET
https://diese-domain-existiert-hoffentlich-nicht-xyz123abc.invalid/status
giving up after 1 attempt(s): Get
"https://diese-domain-existiert-hoffentlich-nicht-xyz123abc.invalid/status":
dial tcp: lookup diese-domain-existiert-hoffentlich-nicht-xyz123abc.invalid
on 127.0.0.53:53: no such host
```

Interessant hier: Der Fehler kommt schon bei `terraform plan`, nicht erst bei `apply`. Data Sources werden ausgewertet, sobald Terraform den Plan berechnet, weil ihr Wert ja Teil des Plans sein kann - Terraform muss also bereits beim Planen eine echte HTTP-Anfrage stellen. Das ist ein guter Beleg dafür, dass "kostet nichts und braucht keine echte Infrastruktur" (siehe oben) für Data Sources nicht uneingeschränkt gilt.

**Fix:** eine erreichbare URL eintragen, z.B. `https://example.com`.

## Fehler beim Apply: Provider und API

Übung 7 und 8 zeigen zwei generische Varianten. Wer mit dem `docker`-Provider arbeitet (lokal installiertes Docker, kein Cloud-Zugang nötig), dem begegnen zusätzlich weitere, sehr reale Fehlerarten - alle live reproduziert:

- **Name bereits vergeben**: Existiert bereits (außerhalb von Terraform) ein Container mit demselben Namen, den `docker_container` verwenden soll:

  ```text
  Error: Unable to create container: Error response from daemon: Conflict. The
  container name "/eigene-app" is already in use by container
  "e456a5e77987...". You have to remove (or rename) that container to be able
  to reuse that name.
  ```

  Lösung: den fremden Container umbenennen/entfernen (`docker rm <name>`) oder in der eigenen Konfiguration einen anderen Namen wählen.

- **Image existiert nicht**: Tippfehler im Image-Tag, oder die angegebene Version wurde nie veröffentlicht:

  ```text
  Error: Unable to read Docker image into resource: unable to pull image
  nginx:diese-version-gibt-es-nicht: error pulling image
  nginx:diese-version-gibt-es-nicht: Error response from daemon: manifest for
  nginx:diese-version-gibt-es-nicht not found: manifest unknown: manifest unknown
  ```

  Lösung: den Image-Namen bzw. Tag korrigieren, z.B. auf [Docker Hub](https://hub.docker.com/_/nginx/tags) nachschauen, welche Tags tatsächlich existieren.

- **Port bereits belegt**: Läuft bereits ein anderer Prozess oder Container auf demselben Host-Port:

  ```text
  Error: Bind for 0.0.0.0:8080 failed: port is already allocated
  ```

  Lösung: einen anderen `external`-Port wählen oder den blockierenden Prozess/Container beenden. (Dieser eine Fehler ist zur Abwechslung nicht live reproduziert, sondern die bekannte Standard-Fehlermeldung von Docker - in dieser Übungsumgebung lässt sich Container-Networking generell nicht vollständig testen.)

- **Docker-Daemon läuft nicht**: Der `docker`-Provider braucht einen laufenden Docker-Daemon, um überhaupt etwas tun zu können - `docker version` zeigt dann nur den `Client`-, keinen `Server`-Abschnitt, und `terraform apply` scheitert mit einer Verbindungsfehlermeldung. Lösung: Docker Desktop/den Docker-Daemon starten.

Der gemeinsame Nenner mit Übung 7 und 8: Auch hier ist die Konfiguration selbst syntaktisch und strukturell einwandfrei - `validate` und meist auch `plan` würden anstandslos durchlaufen. Der Fehler entsteht erst im Zusammenspiel mit der realen Außenwelt (Dateisystem, Netzwerk, Docker-Daemon), und genau deshalb lässt er sich auch nicht früher abfangen. Bei einem echten Cloud-Provider (Azure, AWS, GCP, ...) begegnen euch dieselben Fehlerklassen - abgelaufene Anmeldedaten, Namenskonflikte, bereits existierende, aber nicht im State bekannte Ressourcen (dafür gibt es `terraform import`) - nur mit anderen Fehlertexten.

## Nützliche Werkzeuge

- `terraform validate` - prüft Syntax und Referenzen, ohne echte Ressourcen anzufassen.
- `terraform fmt` - formatiert die Konfiguration einheitlich (mehr dazu im nächsten Kapitel).
- `terraform console` - öffnet eine interaktive Konsole, in der sich einzelne Ausdrücke (z.B. `var.content` oder Funktionen wie `upper("test")`) isoliert testen lassen, ohne einen ganzen `apply` anzustoßen.
- `TF_LOG=DEBUG terraform apply` - aktiviert ausführliches Logging, inklusive der rohen HTTP-Anfragen an den Provider. Hilfreich, wenn eine Fehlermeldung zu vage ist, um die Ursache zu erkennen.
