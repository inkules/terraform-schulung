# CI/CD-Pipeline für Terraform

Bisher lief `terraform apply` immer lokal, mit den eigenen Zugangsdaten. Für ein Team-Setup ist das auf Dauer keine gute Idee: Jeder hat potenziell andere Berechtigungen, niemand sieht, wer wann was geändert hat, und ein Review vor der Änderung findet höchstens informell statt. Dieses Kapitel zeigt, wie sich der komplette Workflow aus den vorherigen Kapiteln - `init`, `fmt`, `validate`, `plan`, `apply` - stattdessen in eine CI/CD-Pipeline verlagert.

Bewusst ohne konkretes YAML eines bestimmten Anbieters: Die Konzepte sind bei GitHub Actions, GitLab CI, Azure DevOps, Jenkins & Co. praktisch identisch, nur die Syntax drumherum unterscheidet sich. Wer die Konzepte einmal verstanden hat, findet sich in der Pipeline-Sprache des eigenen Teams schnell zurecht - eine Vergleichstabelle dazu gibt es am Ende des Kapitels.

## Die drei Stages

Eine typische Terraform-Pipeline besteht aus drei aufeinander aufbauenden Stages:

1. **Validate**: `terraform init`, `terraform fmt -check` und `terraform validate` - bei jedem Push und jedem Pull Request. Schnell, kostenlos, fängt die Fehlerklassen aus dem [Troubleshooting](../02-module-und-deployment/01-troubleshooting/00-troubleshooting.md)-Kapitel ab, bevor irgendjemand den Plan überhaupt anschaut.
2. **Plan**: `terraform plan`, das Ergebnis wird als Pipeline-Artefakt gespeichert - ebenfalls bei jedem Push und PR. So sieht ein Reviewer in der Pull-Request-Pipeline genau, was sich ändern würde, ohne dass schon irgendetwas passiert ist.
3. **Apply**: wendet **genau den geprüften Plan** aus Stage 2 an (`terraform apply tfplan`, nicht `terraform apply` mit einem neuen, ungeprüften Plan) - und nur auf dem `main`-Branch, nie direkt aus einem Pull Request.

In pseudocodeartigem Ablauf (keine echte Syntax, nur das Prinzip):

```text
stage "validate":
  on: push, pull_request
  run: terraform init && terraform fmt -check && terraform validate

stage "plan":
  needs: validate
  on: push, pull_request
  run: terraform plan -out=tfplan
  publish artifact: tfplan

stage "apply":
  needs: plan
  on: push to main
  requires: manuelles Approval
  download artifact: tfplan
  run: terraform apply tfplan
```

Der Grund, den Plan als Artefakt weiterzureichen statt in der Apply-Stage einen neuen zu erzeugen: Zwischen Plan- und Apply-Stage können Minuten oder (bei manuellem Approval) auch Stunden vergehen. Ein neuer `terraform plan` zum Zeitpunkt des Apply könnte inzwischen etwas anderes ergeben, z.B. weil sich jemand anderes in der Zwischenzeit an derselben Infrastruktur zu schaffen gemacht hat. Wird stattdessen der ursprünglich geprüfte Plan angewendet, ist garantiert, dass genau das passiert, was reviewt wurde.

## Authentifizierung ohne interaktiven Login

Lokal meldet ihr euch interaktiv an (z.B. `az login`, `aws configure` oder ähnlich, je nach Provider). Ein Pipeline-Job hat keinen Menschen, der das für ihn erledigen kann - stattdessen kommen technische Zugangsdaten (Service Principal, IAM-Rolle, Service Account) zum Einsatz, die als **Umgebungsvariablen** injiziert werden. Der jeweilige Provider liest sie automatisch, ganz ohne Änderung am `provider`-Block:

| Provider | Übliche Umgebungsvariablen |
| --- | --- |
| Azure (`azurerm`) | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` |
| AWS (`aws`) | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| Google Cloud (`google`) | `GOOGLE_CREDENTIALS` |

Das Prinzip bleibt bei jedem Provider gleich: Die Werte liegen verschlüsselt in der Secret-Verwaltung der jeweiligen CI/CD-Plattform (idealerweise verknüpft mit einem echten Secret-Manager wie Azure Key Vault oder AWS Secrets Manager statt im Klartext hinterlegt) und werden zur Laufzeit injiziert - genau das Prinzip aus [Variablen und Secrets](../02-module-und-deployment/04-variablen-und-secrets/00-variablen-und-secrets.md), nur auf Pipeline-Ebene statt lokal per `TF_VAR_`.

## Remote State

Aus [Der Terraform State](../01-grundlagen/04-state/00-state.md) kennt ihr den `backend`-Block für Remote State. In der Pipeline wird er oft bewusst **leer** gelassen und die eigentlichen Werte erst beim `terraform init` über `-backend-config` übergeben:

```hcl
terraform {
  backend "<typ>" {}
}
```

```bash
terraform init -backend-config="..." -backend-config="..."
```

Der Vorteil: Dieselbe Konfiguration lässt sich für mehrere Umgebungen mit unterschiedlichem State-Backend verwenden (z.B. ein anderer State-Pfad pro Umgebung), ohne den `backend`-Block selbst anzufassen oder zu committen. Details zu den beiden Flags, die dabei helfen (`-migrate-state`, `-reconfigure`), stehen im State-Kapitel.

⚠️ Ohne einen tatsächlich konfigurierten Remote-Backend-Typ (z.B. `s3`, `azurerm`, `gcs` oder `remote` für Terraform Cloud) bleibt der State lokal auf dem Pipeline-Runner - und ist nach dem Job wieder weg. Für den produktiven Einsatz braucht es also immer einen echten, dauerhaften Speicherort für den State.

## Manuelles Approval vor dem Apply

Damit nicht jeder Merge nach `main` automatisch und ohne menschliche Kontrolle Infrastruktur verändert, lässt sich die Apply-Stage an eine Freigabe koppeln: Validate und Plan laufen automatisch durch, die Pipeline pausiert dann aber vor dem Apply, bis eine berechtigte Person den Plan geprüft und freigegeben hat. Jede CI/CD-Plattform nennt und implementiert das etwas anders (siehe Tabelle unten), das Prinzip ist aber überall dasselbe: ein Gate zwischen automatisiertem Plan und tatsächlicher Änderung.

## Vergleichstabelle: dieselben Konzepte, andere Namen

| Konzept | GitHub Actions | GitLab CI | Azure DevOps | Jenkins |
| --- | --- | --- | --- | --- |
| Pipeline-Definition | `.github/workflows/*.yml` | `.gitlab-ci.yml` | `azure-pipelines.yml` | `Jenkinsfile` |
| Mehrere Stages | `jobs` + `needs` | `stages` | `stages` | `stages` (Declarative Pipeline) |
| Artefakt zwischen Stages | `actions/upload-artifact` | `artifacts: paths:` | Publish/Download Artifact | `archiveArtifacts` / `stash` |
| Secrets | Repository/Organization Secrets | CI/CD Variables (maskiert) | Variable Groups, ggf. mit Key Vault | Credentials Plugin |
| Manuelles Gate | Environment mit Required Reviewers | `when: manual` | Environment mit Approvals | `input`-Step |

## Selbst ausprobieren

Für dieses Kapitel gibt es bewusst keinen Übungsordner - eine echte Pipeline braucht immer ein konkretes CI/CD-System (GitHub Actions, GitLab CI, ...) mit eigenem Projekt, das sich nicht lokal nachstellen lässt. Der beste nächste Schritt: eines der lauffähigen `local`-Provider-Beispiele aus diesem Kurs nehmen, z.B. [Was ist Terraform?](../01-grundlagen/01-was-ist-terraform/00-was-ist-terraform.md), und versuchsweise eine minimale Pipeline in der eigenen CI/CD-Plattform bauen, die nur die Validate-Stage umsetzt (`terraform init`, `terraform fmt -check`, `terraform validate`) - das lässt sich ganz ohne Secrets oder Remote State ausprobieren, weil der `local`-Provider keinen Cloud-Zugang braucht.
