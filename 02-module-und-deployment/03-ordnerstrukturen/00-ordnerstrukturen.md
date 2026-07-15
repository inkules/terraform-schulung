# Ordnerstrukturen

Eine durchdachte Ordnerstruktur ist einer der wichtigsten Faktoren dafür, dass ein Terraform-Projekt auch nach Monaten oder mit mehreren Mitwirkenden noch verständlich und wartbar bleibt. Dieses Kapitel zeigt eine bewährte Struktur und die Gründe dahinter.

## Warum Struktur wichtig ist

Bei kleinen Projekten reicht oft eine einzelne `main.tf`. Sobald aber mehrere Umgebungen (z.B. dev, staging, prod) oder mehrere Teams hinzukommen, führt eine unstrukturierte Ablage schnell zu Problemen:

- Unklar, welche Ressourcen zu welcher Umgebung gehören
- Ein Fehler in einer Datei kann versehentlich Produktions-Ressourcen beeinflussen
- Wiederverwendbarer Code wird dupliziert statt geteilt
- Der `terraform.tfstate` einer Umgebung wird versehentlich mit einer anderen vermischt

## Trennung nach Dateien

Auch innerhalb eines einzelnen Terraform-Ordners lohnt es sich, die Konfiguration nach Zweck auf mehrere Dateien aufzuteilen, anstatt alles in eine `main.tf` zu schreiben:

```text
.
├── main.tf          # Haupt-Ressourcen
├── variables.tf      # Definition aller Variablen
├── outputs.tf         # Definition aller Outputs
├── providers.tf       # Provider- und Terraform-Block
└── terraform.tfvars   # Werte für die Variablen
```

Terraform liest beim Ausführen automatisch alle `.tf`-Dateien im Ordner ein - die Aufteilung dient also ausschließlich der Lesbarkeit, nicht der Funktion.

## Trennung nach Umgebungen

Für mehrere Umgebungen hat sich folgende Struktur bewährt, bei der jede Umgebung einen eigenen State besitzt:

```text
.
├── modules/
│   └── webapp/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── staging/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        └── terraform.tfvars
```

Jede Umgebung ruft dabei das gemeinsame Modul aus `modules/` mit ihren eigenen Werten auf, z.B. in `environments/dev/main.tf`:

```hcl
module "webapp" {
  source = "../../modules/webapp"

  environment  = "dev"
  sku_name     = "B1"
  instance_count = 1
}
```

Durch diese Trennung wird verhindert, dass Änderungen an einer Umgebung versehentlich eine andere betreffen, da `terraform apply` immer nur im Ordner der jeweiligen Umgebung ausgeführt wird und jede Umgebung ihren eigenen State hat.

## Namenskonventionen

Zusätzlich zur Ordnerstruktur helfen einheitliche Namenskonventionen dabei, die Konfiguration übersichtlich zu halten:

- Ressourcennamen und Variablen in `snake_case` (z.B. `resource_group_name`)
- Sprechende, eindeutige Namen statt generischer Bezeichner wie `main` oder `test`
- Ein einheitliches Präfix für Azure-Ressourcen, z.B. `rg-`, `app-`, `plan-`, um den Ressourcentyp im Namen erkennbar zu machen

## Zusammenfassung

Eine klare Trennung nach Dateien innerhalb eines Projekts und nach Umgebungen auf Ordnerebene, kombiniert mit wiederverwendbaren Modulen, ist die Grundlage für skalierbare Terraform-Projekte. Wie Module konkret aufgebaut werden, wird im Kapitel [Module implementieren](../06-module-implementieren/00-module-implementieren.md) behandelt.

## Selbst ausprobieren

Dieser Ordner selbst ist nach dem Muster aus "Trennung nach Dateien" aufgebaut: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf` und `terraform.tfvars` liegen als eigene Dateien nebeneinander, statt alles in eine einzige Datei zu packen:

```bash
cd 02-module-und-deployment/03-ordnerstrukturen
terraform init
terraform apply
```

Terraform liest alle `.tf`-Dateien im Ordner automatisch zusammen, die Werte für `projekt_name` und `umgebung` kommen dabei aus `terraform.tfvars`. Im Ordner `output/` landet danach eine Datei, deren Name und Inhalt sich aus genau diesen Werten zusammensetzen. Ändert die Werte in `terraform.tfvars` und beobachtet, wie sich Dateiname und Inhalt nach einem erneuten `terraform apply` anpassen.
