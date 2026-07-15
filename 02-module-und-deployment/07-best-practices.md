# Best Practices für den Alltag

Kein neues Konzept, sondern eine Sammlung kurzer, praktischer Tipps für den täglichen Umgang mit Terraform - Dinge, die sich nicht in ein einzelnes Kapitel einsortieren lassen, aber in echten Projekten schnell einen Unterschied machen. Kein Übungsordner, einfach zum Merken.

## Provider- und Terraform-Versionen pinnen

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

Ohne Versionsangabe zieht `terraform init` beim nächsten Mal ungefragt die neueste Provider-Version - die kann Breaking Changes enthalten. Die Syntax dahinter, die sogenannten Version Constraints:

| Operator | Bedeutung | Beispiel |
| --- | --- | --- |
| `=` (oder nichts) | Exakt diese Version | `= 4.2.0` erlaubt nur `4.2.0` |
| `!=` | Diese Version ausschließen | `!= 4.3.0` erlaubt alles außer `4.3.0` |
| `>`, `>=`, `<`, `<=` | Klassischer Vergleich | `>= 1.9, < 2.0` erlaubt `1.9` bis vor `2.0` |
| `~>` | "Pessimistic Constraint": nur die letzte angegebene Stelle darf steigen | `~> 4.0` erlaubt `4.x`, aber nicht `5.0` · `~> 4.1.0` erlaubt nur `4.1.x` (Patches), nicht `4.2.0` |

`~>` ist der in der Praxis mit Abstand am häufigsten verwendete Operator: großzügig genug für Bugfix- und Minor-Updates, aber ein Sicherheitsnetz gegen unerwartete Major-Versionen mit Breaking Changes. Mehrere Bedingungen lassen sich wie oben bei `required_version` mit Komma kombinieren (UND-verknüpft). Die `.terraform.lock.hcl` (siehe [Terraform CLI im Überblick](../01-grundlagen/10-terraform-cli-im-ueberblick.md)) fixiert zusätzlich die exakte, tatsächlich verwendete Version innerhalb dieser Bandbreite und gehört ins Repository.

## Vor jedem Apply den Plan wirklich lesen

`terraform apply` ohne vorherigen, bewusst gelesenen `plan` ist der häufigste Weg zu einer unerwarteten Änderung. Besonders auf `-/+` (Replace) achten - das kann bei einer Datenbank oder einem Storage Account Datenverlust bedeuten (siehe [Replace und Lifecycle](../01-grundlagen/08-replace-und-lifecycle/00-replace-und-lifecycle.md)). `-auto-approve` ist etwas für CI/CD-Pipelines mit vorgelagertem Review, nicht für den lokalen Alltag.

## Module klein und fokussiert halten

Ein Modul sollte eine Aufgabe haben, keine zehn. Ein Modul, das gleichzeitig Netzwerk, Datenbank und App-Deployment erledigt, lässt sich schwer wiederverwenden und schwer testen. Lieber mehrere kleine Module kombinieren (siehe [Module und Outputs](../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md)) als ein großes "Macht-alles"-Modul.

## Immer description setzen

Bei `variable`- und `output`-Blöcken kostet `description` eine Zeile und spart jedem, der die Konfiguration später liest (auch dem zukünftigen Ich), das Rätselraten, wofür ein Wert gedacht ist. Gilt besonders für Module, die andere Leute aufrufen sollen.

## Zusammengehörige Variablen gruppieren

Statt vieler einzelner loser Variablen lohnt sich ab einer gewissen Anzahl ein strukturierter `object`-Typ:

```hcl
variable "app_config" {
  description = "Konfiguration der App"
  type = object({
    name           = string
    sku            = string
    instance_count = number
  })
}
```

Das verhindert, dass eine Ressource plötzlich zehn einzelne `var.xxx`-Argumente braucht, und macht auf einen Blick klar, welche Werte logisch zusammengehören.

## Ressourcen sinnvoll benennen: this

Der Ressourcenname (das zweite Wort in `resource "typ" "name" { ... }`) ist frei wählbar - in vielen realen Projekten taucht dabei immer wieder derselbe Name auf: `this`. Keine besondere Terraform-Syntax, sondern reine Konvention: Kommt eine Ressource in einem Modul nur einmal bzw. als einzige ihres Typs vor, nennt man sie `this` statt sich einen eigenen Namen auszudenken - spart unnötige Bikeshedding-Diskussionen und ist in der Community weit verbreitet (z.B. in den offiziellen `terraform-aws-modules`):

```hcl
resource "local_file" "this" {
  filename = "${path.module}/greeting.txt"
  content  = "Hallo Terraform!"
}
# Referenz: local_file.this.content
```

Gibt es dagegen mehrere unterschiedliche Ressourcen desselben Typs im selben Modul, braucht jede einen sprechenden eigenen Namen, z.B. `local_file.geheim` und `local_file.oeffentlich` statt zweimal `this`. Bei `for_each` (siehe [Schleifen, Bedingungen und Collections](../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md)) ist `this` genauso üblich - referenziert wird eine einzelne Instanz dann z.B. als `local_file.this["alice"].content`, statt eines Index wie bei `count`.

## Konsistente Formatierung erzwingen, nicht nur empfehlen

`terraform fmt -check` als Pflichtschritt in der CI-Pipeline (siehe [CI/CD-Pipeline für Terraform](../04-ci-cd/01-ci-cd-pipeline.md)) statt als bloße Empfehlung im Wiki - sonst wird es garantiert irgendwann vergessen. Dasselbe gilt für `terraform validate`.

## Remote State ist keine Kür, sondern Pflicht im Team

Lokaler State funktioniert nur, solange eine einzelne Person allein arbeitet. Sobald mehr als eine Person denselben State braucht, ist ein Remote Backend mit Locking (siehe [Der Terraform State](../01-grundlagen/04-state/00-state.md)) keine Optimierung mehr, sondern die Grundvoraussetzung dafür, dass sich niemand gegenseitig überschreibt.

## Ressourcen konsequent taggen

Bei Cloud-Ressourcen (Azure, AWS, GCP) hilft ein einheitliches Tagging-Schema (z.B. `environment`, `owner`, `cost-center`) enorm bei Kostenzuordnung und Aufräumaktionen. Am saubersten über eine gemeinsame `locals`-Map, die an jede Ressource weitergereicht wird, statt Tags einzeln pro Ressource zu wiederholen.

## Selbst ausprobieren

Für dieses Kapitel gibt es bewusst keinen Übungsordner - es sind Gewohnheiten und Konventionen, keine neue Terraform-Syntax. Am besten direkt in den bisherigen Übungsordnern anwenden: z.B. beim nächsten Durchlauf durch [Module und Outputs](../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md) bewusst auf `description`-Felder achten, oder in [Der Terraform State](../01-grundlagen/04-state/00-state.md) nochmal nachlesen, warum Remote State im Team kein "nice to have" ist.
