# Terraform-Schulung

Eine praxisorientierte Terraform-Schulung: von den Grundlagen über eine echte, laufende App bis zu CI/CD - komplett ohne Cloud-Account. Die meisten Kapitel bestehen aus einer `.md`-Datei (Theorie) mit lauffähigem, getestetem Terraform-Code direkt daneben zum Selbstausprobieren; ein paar rein konzeptionelle Kapitel (z.B. Best Practices, Eigene App erstellen) kommen bewusst ohne Übungsordner aus.

## Voraussetzungen

- [Terraform CLI](https://developer.hashicorp.com/terraform/install)
- VS Code + Extension **"HashiCorp Terraform"**
- Git
- Optional, für einzelne Zusatzbeispiele (`docker`-Provider in ein paar Kapiteln): [Docker](https://docs.docker.com/get-docker/), lokal installiert und gestartet - für keinen Übungsordner zwingend erforderlich

Kein Cloud-Account nötig - die gesamte Schulung läuft lokal über den `local`-Provider.

## Struktur

| # | Kapitel | Inhalt |
| --- | --- | --- |
| 01 | [Grundlagen](01-grundlagen/) | Was ist Terraform, HCL-Syntax, Variablen, State, Schleifen/Bedingungen, Module (inkl. eigenem Modul mit `templatefile()`), Module erweitert (Verkettung, Verschachtelung, Validierung), Replace/Lifecycle, Datenquellen (`data`), CLI-Referenz |
| 02 | [Module und Deployment](02-module-und-deployment/) | Troubleshooting anhand kaputter Beispiele, VS Code & `terraform fmt`, Ordnerstrukturen, Variablen- und Secrets-Handling, Terraform Workspaces, Module mit `for_each`, Best Practices für den Alltag |
| 03 | [Eigene App erstellen](03-eigene-app-erstellen/) | Konzeptionell: eine echte Azure Web App mit Terraform (kein Übungsordner, kein Cloud-Zugang nötig zum Lesen) |
| 04 | [CI/CD](04-ci-cd/) | CI/CD-Pipeline für Terraform - plattform-neutral (GitHub Actions, GitLab CI, Azure DevOps, Jenkins, ...) |

Die Kapitel sind bewusst so sortiert, dass die Grundlagen komplett am dependency-freien `local`-Provider gefestigt werden, bevor es an einem konkreten Cloud-Beispiel (Kapitel 3) und der Automatisierung davon (Kapitel 4) weitergeht.

## Ein Kapitel durcharbeiten

Jeder Übungsordner ist eigenständig lauffähig:

```bash
cd 01-grundlagen/01-was-ist-terraform
terraform init
terraform plan
terraform apply
```

Am Ende einer Übung mit `terraform destroy` wieder aufräumen.

## Playground

Im Ordner [`playground/`](playground/) liegen acht kleine Zusatzaufgaben zum aktiven Üben - Ausgangspunkt vorgegeben, Rest selbst bauen, mit getesteter Lösung zum Vergleichen. Unabhängig von den Kapiteln lösbar, ergeben aber am meisten Sinn nach dem jeweils verlinkten Thema.

## Hinweis zu Secrets

`.gitignore` schließt u.a. `.terraform/`, State-Dateien und generierte Output-Dateien aus. Details zum Umgang mit Secrets im Kapitel [Variablen und Secrets](02-module-und-deployment/04-variablen-und-secrets/00-variablen-und-secrets.md).
