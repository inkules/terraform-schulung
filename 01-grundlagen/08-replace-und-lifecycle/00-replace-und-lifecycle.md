# Replace und Lifecycle

Nicht jede Änderung an einer Konfiguration führt zu einem einfachen Update. Manchmal muss Terraform eine Ressource komplett löschen und neu anlegen, um eine Änderung umzusetzen. Dieses Kapitel zeigt, woran man das im Plan erkennt, wie man es gezielt selbst auslöst - und wie sich das Verhalten über den `lifecycle`-Block beeinflussen lässt.

## Die vier Plan-Symbole

Bei `terraform plan` tauchen im Wesentlichen vier Symbole auf:

- `+` - die Ressource wird neu erstellt.
- `~` - die Ressource wird in-place aktualisiert (bestehendes Objekt bleibt erhalten, nur einzelne Attribute ändern sich).
- `-` - die Ressource wird gelöscht.
- `-/+` bzw. `+/-` - die Ressource wird **ersetzt**: gelöscht und neu erstellt. Welche der beiden Reihenfolgen verwendet wird, hängt vom `lifecycle`-Block ab (dazu gleich mehr).

Ob eine Änderung ein Update oder ein Replace auslöst, entscheidet der Provider pro Attribut. Manche Attribute lassen sich "on the fly" ändern, andere sind Teil dessen, was die Ressource überhaupt erst ausmacht, und erzwingen deshalb ein Replace.

## Live-Beispiel: local_file

Beim `local_file`-Provider ist praktisch jede inhaltliche Änderung ein Replace, weil die `id` der Ressource ein Hash des Inhalts ist. Ändert sich der Inhalt, ändert sich zwangsläufig die Identität:

```bash
terraform plan -var="content=Version 2"
```

```text
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
+/- create replacement and then destroy

  # local_file.app must be replaced
+/- resource "local_file" "app" {
      ~ content              = "Version 1" -> "Version 2" # forces replacement
      ~ id                   = "db3cbc01..." -> (known after apply)
        # (weitere berechnete Attribute gekürzt)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Der Kommentar `# forces replacement` direkt hinter dem geänderten Attribut zeigt genau, welcher Wert das Replace auslöst. Das Symbol ist hier bewusst `+/-` statt `-/+` - das mitgelieferte Beispiel hat nämlich schon `create_before_destroy` gesetzt (siehe unten). Ohne diese Einstellung sähe derselbe Plan mit `-/+ destroy and then create replacement` aus, also in umgekehrter Reihenfolge.

## Nicht jede Ressource ist so extrem wie local_file

`local_file` ist ein Extremfall - dort lässt sich fast nichts in-place ändern, weil die `id` ein Hash des Inhalts ist. Bei den meisten anderen Ressourcen ist das differenzierter: manche Attribute lassen sich live anpassen, andere nicht. Ein gutes, live nachvollziehbares Beispiel ist `docker_container` (der `docker`-Provider braucht lokal installiertes Docker, aber keinen Cloud-Zugang):

```hcl
resource "docker_container" "app" {
  name    = "eigene-app"
  image   = docker_image.nginx.image_id  # Änderung -> Replace
  restart = "unless-stopped"             # Änderung -> in-place Update (~)
}
```

Live getestet: Ändert sich `image`, zeigt der Plan `# forces replacement` - ein laufender Container kann sein Image nicht im laufenden Betrieb austauschen, das entspricht auch dem `docker update`-Verhalten der Docker-CLI. Ändert sich dagegen nur `restart`, zeigt der Plan `will be updated in-place` - genau wie `docker update --restart=...` das ohne Neustart des Containers hinbekommt. Welche Attribute bei einer Ressource ein Replace auslösen, steht in der Regel in der jeweiligen [Provider-Dokumentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) beim jeweiligen Attribut - bei Cloud-Providern wie Azure, AWS oder GCP gilt dasselbe Prinzip, dort erzwingen meist Attribute wie Name oder Region ein Replace, während z.B. Tags sich in-place ändern lassen.

## Replace manuell erzwingen: `terraform apply -replace`

Manchmal soll eine Ressource neu erstellt werden, obwohl sich an der Konfiguration nichts geändert hat - z.B. um ein defektes Objekt zu regenerieren. Dafür gibt es `-replace`, ganz ohne die Konfiguration anzufassen:

```bash
terraform apply -replace="local_file.app"
```

```text
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
+/- create replacement and then destroy

  # local_file.app will be replaced, as requested
+/- resource "local_file" "app" {
      ~ id = "57ce28f6..." -> (known after apply)
        # (weitere berechnete Attribute gekürzt)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
local_file.app: Creating...
local_file.app: Creation complete after 0s [id=57ce28f6...]
local_file.app (deposed object 0973fb86): Destroying... [id=57ce28f6...]
local_file.app: Destruction complete after 0s
```

`-replace` ist der moderne Ersatz für den älteren Befehl `terraform taint` (seit Terraform 0.15.2 als eigener Befehl veraltet). Falls euch `taint` in älteren Projekten oder Anleitungen begegnet: gleiche Idee, andere Syntax.

## Der lifecycle-Block

Innerhalb einer Ressource lässt sich mit einem `lifecycle`-Block das Replace-Verhalten beeinflussen.

### create_before_destroy

Standardmäßig löscht Terraform bei einem Replace zuerst die alte Ressource und legt danach die neue an. Mit `create_before_destroy = true` dreht sich das um - erkennbar auch am Plan-Symbol, das von `-/+` zu `+/-` wechselt. Genau das steckt schon in `local_file.app` im mitgelieferten Beispiel:

```hcl
resource "local_file" "app" {
  filename = "${path.module}/output/${var.filename}"
  content  = var.content

  lifecycle {
    create_before_destroy = true
  }
}
```

Beim `apply` ist die Reihenfolge dann tatsächlich vertauscht - erst "Creating", dann "Destroying" der alten (jetzt "deposed" genannten) Instanz:

```text
local_file.app: Creating...
local_file.app: Creation complete after 0s [id=57ce28f6...]
local_file.app (deposed object de3ab678): Destroying... [id=db3cbc01...]
local_file.app: Destruction complete after 0s
```

Das ist immer dann relevant, wenn die alte und die neue Instanz kurzzeitig gleichzeitig existieren müssen oder sollen - z.B. wenn andere Ressourcen fest auf die ID der alten Instanz verweisen, bis die neue vollständig bereitsteht.

### prevent_destroy

Schützt eine Ressource davor, versehentlich gelöscht zu werden - egal ob durch `terraform destroy` oder weil eine Konfigurationsänderung ein Replace auslösen würde:

```hcl
resource "local_file" "geschuetzt" {
  filename = "${path.module}/output/geschuetzt.txt"
  content  = "Diese Datei ist vor destroy geschützt."

  lifecycle {
    prevent_destroy = true
  }
}
```

Ein `terraform destroy` schlägt dann hart fehl, statt die Ressource stillschweigend zu löschen:

```text
Error: Instance cannot be destroyed

  on main.tf line 14:
  14: resource "local_file" "geschuetzt" {

Resource local_file.geschuetzt has lifecycle.prevent_destroy set, but the
plan calls for this resource to be destroyed. To avoid this error and
continue with the plan, either disable lifecycle.prevent_destroy or reduce
the scope of the plan using the -target option.
```

Sinnvoll für Ressourcen, bei denen ein versehentliches Löschen besonders schmerzhaft wäre - eine Datenbank, ein Storage Account mit wichtigen Daten, o.ä.

### Kurzer Rückverweis: ignore_changes

Ein drittes `lifecycle`-Argument, `ignore_changes`, ist an dieser Stelle erwähnenswert, weil es leicht missverstanden wird: Es sorgt dafür, dass Terraform Änderungen an bestimmten Attributen **nach der Erstellung ignoriert** und keinen Diff mehr dafür anzeigt. Es blendet den Wert damit aber nur aus zukünftigen Plänen aus - **nicht** aus dem State. Genau wie bei `sensitive = true` (siehe [Der Terraform State](../04-state/00-state.md)) landet der ursprüngliche Wert weiterhin ganz normal im `terraform.tfstate`.

## Selbst ausprobieren

In diesem Ordner liegt ein Beispiel mit dem `local`-Provider (kein Cloud-Zugang nötig), das alles oben Gezeigte enthält:

```bash
terraform init
terraform apply

# Replace durch Config-Änderung beobachten:
terraform plan -var="content=Version 2"
terraform apply -var="content=Version 2"    # create_before_destroy in Aktion

# Replace ohne Config-Änderung erzwingen:
terraform apply -var="content=Version 2" -replace="local_file.app"

# prevent_destroy erleben:
terraform destroy    # schlägt wegen local_file.geschuetzt fehl
```

Um danach aufzuräumen, muss `prevent_destroy` in `main.tf` bei `local_file.geschuetzt` erst auf `false` gesetzt werden, bevor `terraform destroy` durchläuft - genau das ist ja der Sinn der Übung.
