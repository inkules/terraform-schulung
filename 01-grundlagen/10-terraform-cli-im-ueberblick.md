# Terraform CLI im Überblick

Über die vorherigen Kapitel verteilt sind schon eine ganze Menge `terraform`-Befehle vorgekommen - hier alle an einem Ort, als Nachschlagewerk statt neuem Übungsstoff. Kein eigener Übungsordner in diesem Kapitel, dafür Links zu den Kapiteln, in denen jeder Befehl im Kontext erklärt und live getestet wurde.

## Grundlegender Workflow

| Befehl | Was er tut |
|---|---|
| `terraform init` | Lädt benötigte Provider/Module herunter, richtet den Ordner ein. Immer der erste Befehl in einem neuen Projekt. |
| `terraform fmt` | Formatiert `.tf`-Dateien einheitlich. Mit `-check -diff` nur anzeigen statt ändern. |
| `terraform validate` | Prüft Syntax und Referenzen, ohne Provider/Cloud anzufassen. |
| `terraform plan` | Zeigt, was sich ändern würde - ohne es umzusetzen. |
| `terraform apply` | Setzt den Plan um. Mit `-auto-approve` ohne Rückfrage (Vorsicht). |
| `terraform destroy` | Entfernt alle verwalteten Ressourcen wieder. |

→ [Was ist Terraform?](01-was-ist-terraform/00-was-ist-terraform.md), [Eigene App erstellen](../03-eigene-app-erstellen/01-eigene-app-erstellen.md)

## Werte reinreichen

| Befehl | Was er tut |
|---|---|
| `terraform apply -var="x=y"` | Überschreibt eine einzelne Variable für diesen Lauf. Höchste Priorität. |
| `terraform apply -var-file="datei.tfvars"` | Lädt Werte aus einer bestimmten `.tfvars`-Datei. `terraform.tfvars` und `*.auto.tfvars` werden automatisch geladen. |
| `TF_VAR_name=wert terraform apply` | Variable über eine Umgebungsvariable setzen - praktisch für Secrets. |

→ [Variablen in Terraform](03-variablen-und-dateien/00-variablen-und-dateien.md), [Variablen und Secrets](../02-module-und-deployment/04-variablen-und-secrets/00-variablen-und-secrets.md)

## State inspizieren und reparieren

| Befehl | Was er tut |
|---|---|
| `terraform state list` | Zeigt alle Ressourcen im State. |
| `terraform show` | Zeigt den State im Detail, inklusive aller Attribute. |
| `terraform output` | Zeigt die definierten Outputs. |
| `terraform state mv <a> <b>` | Verschiebt/benennt eine Ressource im State um, ohne sie neu zu erstellen. |
| `terraform state rm <addr>` | Entfernt eine Ressource aus dem State, ohne sie real zu löschen. |
| `terraform apply -refresh-only` | Zeigt Drift zwischen State und Realität, ohne etwas zu ändern. |
| `terraform import <addr> <id>` | Übernimmt eine bereits existierende, reale Ressource in den State. |
| `terraform init -migrate-state` | Bestehenden State beim Backend-Wechsel ins neue Backend mitnehmen. |
| `terraform init -reconfigure` | Backend neu konfigurieren, alten State dabei nicht migrieren. |

→ [Der Terraform State](04-state/00-state.md)

## Gezielt ersetzen

| Befehl | Was er tut |
|---|---|
| `terraform apply -replace="<addr>"` | Erzwingt Neuerstellung einer Ressource, auch ohne Config-Änderung. Moderner Ersatz für das veraltete `terraform taint`. |

→ [Replace und Lifecycle](08-replace-und-lifecycle/00-replace-und-lifecycle.md)

## Umgebungen

| Befehl | Was er tut |
|---|---|
| `terraform workspace new <name>` | Legt einen neuen, isolierten State-Workspace an. |
| `terraform workspace select <name>` | Wechselt den aktiven Workspace. |
| `terraform workspace list` | Zeigt alle Workspaces, `*` markiert den aktiven. |

→ [Weg von Copy & Paste](../02-module-und-deployment/05-weg-von-copy-paste/00-weg-von-copy-paste.md)

## Debugging

| Befehl | Was er tut |
|---|---|
| `terraform console` | Interaktive Konsole, um einzelne Ausdrücke/Funktionen isoliert zu testen. |
| `TF_LOG=DEBUG terraform apply` | Ausführliches Logging, inklusive der rohen Anfragen an den Provider. |

→ [Troubleshooting](../02-module-und-deployment/01-troubleshooting/00-troubleshooting.md)

## Sonstiges

| Befehl | Was er tut |
|---|---|
| `terraform -version` | Zeigt die installierte Terraform- und Provider-Version. |
| `terraform providers` | Zeigt, welche Provider die aktuelle Konfiguration verwendet. |
