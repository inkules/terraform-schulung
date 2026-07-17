# Eigene App erstellen

"Eine App erstellen" ist kein plattformneutraler Begriff - es ist im Kern das Vokabular von Azure. Azure App Service bietet mit der **Web App** eine fertige Ressource für genau das: eine laufende Anwendung, ohne selbst eine virtuelle Maschine zu verwalten. Andere Clouds haben ungefähre Entsprechungen (AWS App Runner/Elastic Beanstalk, Google Cloud Run/App Engine), aber keine mit identischem Namen oder identischer Ressourcenstruktur. Dieses Kapitel bleibt deshalb bewusst bei Azure als konkretem Beispiel, erklärt das Prinzip aber so, dass es sich auf jeden anderen Cloud-Provider übertragen lässt.

⚠️ **Rein konzeptionell:** Für dieses Kapitel gibt es keinen Übungsordner und keinen Cloud-Zugang in dieser Schulung. Der Code unten ist syntaktisch korrekt und folgt der offiziellen [azurerm-Provider-Dokumentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app), wurde aber **nicht live getestet** - anders als der Rest dieses Kurses, wo jedes Beispiel tatsächlich ausgeführt wurde. Wer einen eigenen Azure-Account hat, kann das Beispiel gerne selbst ausprobieren.

## Voraussetzung: Bei Azure anmelden

Anders als der `local`-Provider braucht `azurerm` eine echte Anmeldung. Am einfachsten lokal über die Azure CLI, **vor** dem ersten `terraform init`/`plan`:

```bash
az login
```

Das öffnet einen Browser zum Login und wählt danach ein Abonnement (Subscription) aus - bei mehreren Abos ggf. zusätzlich `az account set --subscription "<name-oder-id>"`. Der `azurerm`-Provider erkennt diese CLI-Session automatisch, ganz ohne Zugangsdaten in der Konfiguration:

```hcl
provider "azurerm" {
  features {}
}
```

Der `features {}`-Block ist bei `azurerm` Pflicht, auch leer - ohne ihn bricht schon `terraform init` ab. Für CI/CD-Pipelines (siehe [CI/CD-Pipeline für Terraform](../04-ci-cd/01-ci-cd-pipeline.md)) ist `az login` keine Option, dort übernimmt stattdessen ein Service Principal per Umgebungsvariablen die Anmeldung - gleiches Prinzip wie bei `TF_VAR_`-Umgebungsvariablen für Secrets, nur provider-eigene Variablen (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`).

## Die drei Bausteine einer Azure Web App

Eine laufende Web-App in Azure besteht aus drei Ressourcen, die aufeinander aufbauen:

1. **`azurerm_resource_group`** - der organisatorische Container, in dem alle folgenden Ressourcen landen.
2. **`azurerm_service_plan`** - definiert die Recheninstanz (SKU, z.B. `B1` oder `P1v2`) und das Betriebssystem, auf der die App läuft. Mehrere Web Apps können sich einen Service Plan teilen.
3. **`azurerm_linux_web_app`** (oder `azurerm_windows_web_app`) - die eigentliche Anwendung, referenziert den Service Plan.

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-eigene-app"
  location = "West Europe"
}

resource "azurerm_service_plan" "main" {
  name                = "plan-eigene-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-eigene-app-demo"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      docker_image_name   = "nginx:alpine"
      docker_registry_url = "https://index.docker.io"
    }
  }
}
```

Genau dasselbe Muster wie überall in diesem Kurs: `resource`-Block, Attribute, Verweise zwischen Ressourcen (`azurerm_service_plan.main.id`) statt hartcodierter Werte. Der `service_plan_id`-Verweis sorgt dafür, dass Terraform die richtige Reihenfolge beim Erstellen ermittelt - die Web App kann erst entstehen, wenn der Service Plan existiert.

## Wie der Code in die App kommt

`site_config.application_stack` legt fest, was in der Web App läuft. Je nach Bedarf u.a.:

- **`docker_image_name`** + **`docker_registry_url`** (wie oben) - ein Container-Image, ähnlich wie ein lokal laufender Container, nur dass Azure den Container betreibt statt der eigene Rechner. Beide Attribute gehören zusammen, `docker_registry_url` ist Pflicht, sobald `docker_image_name` gesetzt ist.
- **Sprach-Runtime** (z.B. `node_version`, `python_version`, `dotnet_version`) - Azure stellt eine passende Laufzeitumgebung bereit, der Code selbst kommt separat über eine Deployment-Pipeline (siehe [CI/CD-Pipeline für Terraform](../04-ci-cd/01-ci-cd-pipeline.md)) - Terraform erstellt nur die Infrastruktur, nicht den Code-Deploy selbst.

Diese Trennung ist wichtig: Terraform verwaltet die Infrastruktur (welche Web App mit welcher Größe existiert), das eigentliche Deployment des Anwendungscodes läuft meist über ein separates Werkzeug oder einen separaten Pipeline-Schritt.

## Übertragbarkeit auf andere Provider

Das Drei-Ressourcen-Muster (organisatorischer Rahmen → Compute-Plan → laufende App) findet sich in ähnlicher Form bei jedem Cloud-Provider:

| Konzept | Azure | AWS | Google Cloud |
| --- | --- | --- | --- |
| Organisatorischer Rahmen | Resource Group | (kein direktes Äquivalent, eher Tags/Accounts) | Project |
| Recheninstanz/Plan | Service Plan | App Runner Service / Elastic Beanstalk Environment | Cloud Run Service |
| Laufende App | Linux/Windows Web App | App Runner Service (kombiniert) | Cloud Run Service (kombiniert) |

Die Terraform-Ressourcennamen unterscheiden sich (`azurerm_linux_web_app`, `aws_apprunner_service`, `google_cloud_run_v2_service`), das grundlegende Prinzip - Provider, `resource`-Block, Verweise zwischen Ressourcen, `init`/`plan`/`apply`/`destroy` - bleibt exakt dasselbe, das in diesem Kurs durchgehend am `local`-Provider geübt wurde.

## Aufräumen (konzeptionell)

Wie bei jeder Terraform-verwalteten Infrastruktur würde `terraform destroy` alle drei Ressourcen wieder entfernen. Bei echten Cloud-Ressourcen ist das nicht nur Aufräumen, sondern auch bares Geld: Eine laufende Web App verursacht Kosten, solange sie existiert - anders als die überwiegend kostenlosen Beispiele in diesem Kurs.
