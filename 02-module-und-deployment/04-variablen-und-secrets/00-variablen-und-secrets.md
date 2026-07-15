# Variablen und Secrets

[Variablen in Terraform](../../01-grundlagen/03-variablen-und-dateien/00-variablen-und-dateien.md) hat eine Rangfolge gezeigt: `default` < `terraform.tfvars` < `-var`. Das war absichtlich unvollständig - es gibt noch eine vierte Quelle, **Umgebungsvariablen**, die dort bewusst ausgespart wurde. Genau die schließt dieses Kapitel jetzt, und zwar an der Stelle, wo sie richtig wichtig wird: beim Umgang mit Secrets.

## Die Rangfolge, jetzt vollständig

Jede Terraform-Variable `foo` lässt sich über eine Umgebungsvariable `TF_VAR_foo` setzen, ganz ohne Datei oder CLI-Flag:

```bash
export TF_VAR_foo="aus-env"
terraform apply
```

Live getestet, die komplette Kette an einer einzigen Variable mit Default `"aus-default"`:

| Schritt | Gesetzt | Ergebnis |
| --- | --- | --- |
| 1 | nichts | `aus-default` |
| 2 | `TF_VAR_foo=aus-env` | `aus-env` |
| 3 | zusätzlich `terraform.tfvars` mit `foo = "aus-tfvars-datei"` | `aus-tfvars-datei` |
| 4 | zusätzlich `-var="foo=aus-cli"` | `aus-cli` |

Die vollständige Rangfolge lautet also: **`default` < Umgebungsvariable < `terraform.tfvars` < `-var`**. Umgebungsvariablen schlagen den Default, werden aber von jeder Datei und jedem CLI-Flag wieder überschrieben - sie sind die zweitschwächste Quelle, nicht die stärkste.

## Warum ausgerechnet Umgebungsvariablen für Secrets

Aus [Der Terraform State](../../01-grundlagen/04-state/00-state.md) wisst ihr bereits: `sensitive = true` blendet einen Wert nur in der CLI-Ausgabe aus - im `terraform.tfstate` landet er trotzdem im Klartext. Das schützt also nicht vor dem State, sondern nur vor versehentlichem Anzeigen auf dem Bildschirm. Für den Wert selbst gilt eine unabhängige, einfache Grundregel: **Secrets stehen nie in einer Datei, die eingecheckt wird.**

Umgebungsvariablen erfüllen das fast automatisch: Sie existieren nur im Speicher des laufenden Prozesses, landen nie auf der Platte und nie in der Git-Historie - man kann sie schlicht nicht versehentlich committen. Genau deshalb ist das auch das Muster, das CI/CD-Pipelines (siehe [CI/CD-Pipeline für Terraform](../../04-ci-cd/01-ci-cd-pipeline.md)) fast immer nutzen: Das Secret liegt verschlüsselt in der Pipeline-Konfiguration und wird zur Laufzeit als Umgebungsvariable injiziert, exakt nach demselben `TF_VAR_`-Prinzip wie hier lokal.

## Wenn eine Umgebungsvariable nicht reicht

Für die meisten Fälle ist `TF_VAR_` der richtige, einfachste Weg. Für produktive Umgebungen lohnt sich eine Ergänzung: Ein dedizierter Secret-Store, aus dem Terraform den Wert zur Laufzeit über eine `data`-Ressource lädt, statt ihn irgendwo abzulegen (Azure Key Vault, AWS Secrets Manager, Google Secret Manager, HashiCorp Vault - das Prinzip ist überall identisch):

```hcl
data "<secret-store-provider>" "db_password" {
  name = "db-password"
}

resource "..." "main" {
  # ...
  app_settings = {
    DB_PASSWORD = data.<secret-store-provider>.db_password.value
  }
}
```

Der Wert existiert dann nirgends in Textform in der Konfiguration - nur ein Verweis auf den Eintrag im Secret-Store.

## Selbst ausprobieren

In diesem Ordner liegt ein Beispiel mit dem `local`-Provider (kein Cloud-Zugang nötig). `var.app_name` hat einen Default, `var.db_password` bewusst keinen:

```bash
terraform init
terraform apply    # app_name kommt aus dem Default, db_password schlägt fehl:
                    # "No value for required variable"
```

Die vollständige Rangfolge an `app_name` durchspielen:

```bash
TF_VAR_app_name="aus-env" terraform apply          # überschreibt den Default
echo 'app_name = "aus-tfvars"' > terraform.tfvars
TF_VAR_app_name="aus-env" terraform apply          # tfvars gewinnt gegen die Env-Variable
TF_VAR_app_name="aus-env" terraform apply -var="app_name=aus-cli"  # -var gewinnt gegen alles
rm terraform.tfvars
```

Danach `db_password` per Umgebungsvariable setzen:

```bash
TF_VAR_db_password="mein-geheimes-passwort" terraform apply
```
