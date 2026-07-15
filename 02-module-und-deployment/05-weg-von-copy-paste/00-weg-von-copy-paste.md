# Weg von Copy & Paste

Ein sehr verbreitetes Anti-Pattern in gewachsenen Terraform-Projekten: für jede Umgebung (dev, staging, prod) existiert ein eigener Ordner mit fast identischer Konfiguration, kopiert und leicht angepasst. Eine Änderung muss dann drei Mal gemacht werden, und garantiert vergisst irgendwann jemand eine der Kopien zu aktualisieren. Dieses Kapitel zeigt Techniken, um genau das zu vermeiden, bevor im nächsten Kapitel mit Modulen der nächste, größere Schritt folgt.

## Was ihr schon kennt

Ein Teil des Problems ist mit Bordmitteln aus den Grundlagen bereits lösbar:

- **`for_each`/`count`** (siehe [Schleifen, Bedingungen und Collections](../../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md)) vermeiden kopierte Ressourcen-Blöcke für gleichartige Ressourcen.
- **Variablen und `.tfvars`** (siehe [Variablen in Terraform](../../01-grundlagen/03-variablen-und-dateien/00-variablen-und-dateien.md)) vermeiden kopierte Konfigurationswerte.

Was bisher fehlt: eine Möglichkeit, dieselbe Konfiguration mehrfach mit komplett getrenntem State auszuführen - für unterschiedliche Umgebungen, ohne den Ordner zu duplizieren.

## Terraform Workspaces

Ein Workspace ist im Kern nichts anderes als ein benannter, isolierter State innerhalb desselben Konfigurationsordners. Standardmäßig arbeitet jedes Projekt im Workspace `default`. Weitere lassen sich anlegen und wechseln:

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

terraform workspace list      # zeigt alle Workspaces, * markiert den aktiven
terraform workspace select dev
```

Innerhalb der Konfiguration steht der Name des aktuell aktiven Workspace über die eingebaute Variable `terraform.workspace` zur Verfügung - kein `var.`, keine eigene Deklaration nötig:

```hcl
resource "local_file" "config" {
  filename = "${path.module}/output/${terraform.workspace}.txt"
  content  = "Workspace: ${terraform.workspace}"
}
```

Jeder Workspace bekommt dabei automatisch seine eigene State-Datei (lokal unter `terraform.tfstate.d/<workspace>/`), obwohl `main.tf` nur einmal existiert. Ein `terraform apply` im Workspace `dev` hat keinerlei Auswirkung auf den State von `staging` oder `prod`.

## terraform.workspace mit Einstellungen kombinieren

Der eigentliche Clou: `terraform.workspace` lässt sich als Schlüssel in eine Map aus `locals` verwenden, um pro Umgebung unterschiedliche Werte zu ziehen - ganz ohne `if`-Kaskaden oder kopierte Dateien:

```hcl
locals {
  einstellungen_je_workspace = {
    dev     = { sku = "B1", instance_count = 1 }
    staging = { sku = "B2", instance_count = 2 }
    prod    = { sku = "P1v2", instance_count = 3 }
  }

  einstellungen = local.einstellungen_je_workspace[terraform.workspace]
}
```

Eine neue Umgebung hinzuzufügen bedeutet jetzt: eine Zeile in dieser Map ergänzen und einen neuen Workspace anlegen. Kein neuer Ordner, keine kopierte Datei.

## Grenzen von Workspaces

Workspaces sind kein Ersatz für alles: Da sich alle Workspaces dieselbe Konfiguration und denselben Provider teilen, eignen sie sich gut für "dieselbe Infrastruktur, mehrfach mit unterschiedlichen Werten" - aber schlecht, wenn sich Umgebungen strukturell unterscheiden sollen (z.B. Prod hat eine zusätzliche Ressource, die Dev nicht hat) oder unterschiedliche Cloud-Abonnements/Accounts verwenden. Dafür sind separate State-Backends (ein Ordner pro Umgebung, wie in [Ordnerstrukturen](../03-ordnerstrukturen/00-ordnerstrukturen.md) beschrieben) oft die robustere Wahl. Workspaces und die Ordner-Trennung schließen sich nicht aus - beides lässt sich kombinieren.

## Selbst ausprobieren

In diesem Ordner liegt ein lauffähiges Beispiel mit dem `local`-Provider (kein Cloud-Zugang nötig):

```bash
terraform init
terraform apply                    # läuft im Workspace "default"

terraform workspace new dev
terraform apply
terraform workspace new staging
terraform apply
terraform workspace new prod
terraform apply

terraform workspace list
```

Danach liegt im Ordner `output/` für jeden Workspace eine eigene Datei mit den jeweils passenden Werten aus `local.einstellungen_je_workspace` - erzeugt aus ein und derselben Konfiguration.
