# Variablen in Terraform

In Terraform können Variablen verwendet werden, um Konfigurationswerte zu parametrisieren und wiederverwendbar zu machen. Variablen ermöglichen es, die Konfiguration flexibler zu gestalten und unterschiedliche Werte für verschiedene Umgebungen oder Szenarien bereitzustellen.

## Definition von Variablen

Variablen werden in Terraform mit dem `variable`-Block definiert. Jede Variable hat einen Namen und kann optional einen Standardwert, eine Beschreibung und einen Typ haben.

Beispiel für die Definition einer Variablen:

```hcl
variable "filename" {
  description = "Name der Datei, die erstellt wird"
  type        = string
  default     = "output.txt"
}
variable "content" {
  description = "Inhalt der Datei"
  type        = string
  default     = "Hallo aus der Standard-Konfiguration!"
}
```

Der default -Wert wird verwendet, wenn kein anderer Wert für die Variable angegeben wird. Verwendet werden die Variablen dann über `var.<name>`, z.B. in einer Ressource:

```hcl
resource "local_file" "beispiel" {
  filename = "${path.module}/output/${var.filename}"
  content  = var.content
}
```

## TFVars

Neben der Definition von Variablen in der Konfiguration können Werte für diese Variablen auch über separate Dateien bereitgestellt werden. Diese Dateien haben die Endung `.tfvars` und enthalten Key-Value-Paare, die den Variablen zugeordnet werden.

Beispiel für eine `terraform.tfvars`-Datei:

```hcl
filename = "aus-tfvars.txt"
content  = "Ich komme aus der terraform.tfvars-Datei!"
```

Hier werden in einer File einfach nur Variablen für die Konfiguration überschrieben. Diese Datei kann dann beim Ausführen von Terraform automatisch geladen werden.
Die Datei kann mit dem Befehl `terraform apply -var-file="terraform.tfvars"` angegeben werden, um die Werte aus der Datei zu verwenden. Eine Datei namens `terraform.tfvars` (oder `*.auto.tfvars`) wird von Terraform sogar automatisch geladen, ganz ohne diesen Parameter.

## Werte direkt beim Apply übergeben

Zusätzlich zu Default-Werten und `.tfvars`-Dateien lassen sich einzelne Variablen auch direkt auf der Kommandozeile überschreiben, mit `-var`:

```bash
terraform apply -var="filename=cli-datei.txt" -var="content=Ich komme von der Kommandozeile!"
```

Dabei gilt eine feste Rangfolge, falls ein und dieselbe Variable an mehreren Stellen gesetzt wird: Der `default`-Wert aus dem `variable`-Block hat die niedrigste Priorität, Werte aus `terraform.tfvars` überschreiben ihn, und `-var` auf der Kommandozeile hat die höchste Priorität und gewinnt gegenüber allen anderen Quellen.

Diese Rangfolge ist an dieser Stelle bewusst noch unvollständig: Es gibt noch eine vierte Quelle, Umgebungsvariablen - die kommt erst in [Variablen und Secrets](../../02-module-und-deployment/04-variablen-und-secrets/00-variablen-und-secrets.md) dazu, wo sie besonders für den Umgang mit Secrets wichtig wird.

## Selbst ausprobieren

Ein lauffähiges Beispiel mit Variablen und `terraform.tfvars` liegt direkt in diesem Ordner. Es legt eine einzelne lokale Datei an, deren Name (`filename`) und Inhalt (`content`) über Variablen gesteuert werden. Damit lässt sich die Rangfolge direkt beobachten:

```bash
terraform init
terraform apply                                          # nutzt Werte aus terraform.tfvars
terraform apply -var="filename=direkt.txt"                # überschreibt nur den Dateinamen
terraform apply -var="filename=direkt.txt" -var="content=Hallo direkt von der CLI!"
```

Nach jedem Durchlauf lohnt sich ein Blick in den Ordner `output/`, um zu sehen, welche Datei mit welchem Inhalt tatsächlich entstanden ist.

Wer selbst eine Variable von Grund auf bauen will statt nur die vorgegebene zu nutzen: [Playground-Aufgabe 1](../../playground/01-eigene-variable/AUFGABE.md).
