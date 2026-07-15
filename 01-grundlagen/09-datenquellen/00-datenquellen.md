# Datenquellen (data)

Bisher ging es immer um `resource`-Blöcke: Terraform legt etwas an, verwaltet es, ändert oder löscht es wieder. Nicht alles, worauf eine Konfiguration zugreifen muss, soll aber von Terraform verwaltet werden - manchmal reicht es, einen bereits existierenden Wert **nur zu lesen**. Genau dafür gibt es `data`-Blöcke.

## resource vs. data: Verwalten vs. Lesen

- **`resource`** - Terraform erstellt, ändert und löscht das Objekt.
- **`data`** - Terraform liest nur einen bereits vorhandenen Wert. Nichts wird erstellt oder gelöscht, es gibt kein Replace, kein `lifecycle`.

Referenziert wird eine Data Source mit vorangestelltem `data.`, sonst wie eine Ressource: `data.<typ>.<name>.<attribut>`.

## Live-Beispiel: local_file als Data Source

In diesem Ordner liegt eine Datei `VERSION` mit einer einzelnen Versionsnummer - eine ganz gewöhnliche Textdatei, die nicht von Terraform erzeugt wurde. Der `local`-Provider bringt dafür passend eine `local_file`-Data-Source mit, die eine bestehende Datei ausliest:

```hcl
data "local_file" "version" {
  filename = "${path.module}/VERSION"
}

resource "local_file" "deploy_info" {
  filename = "${path.module}/output/deploy-info.txt"
  content  = "Deploye Version: ${trimspace(data.local_file.version.content)}"
}
```

`data.local_file.version.content` liest den Dateiinhalt, `trimspace()` entfernt den Zeilenumbruch am Ende. `local_file.version` selbst ist keine Ressource, sondern nur eine gelesene Datenquelle - sie taucht in `terraform plan` nie mit `+`, `~` oder `-` auf, nur `local_file.deploy_info` wird tatsächlich erstellt.

## Selbst ausprobieren

```bash
terraform init
terraform apply
cat output/deploy-info.txt
```
