# Der Terraform State

Damit Terraform weiß, welche Ressourcen es bereits erstellt hat und wie diese mit der Konfiguration zusammenhängen, führt es Buch über den aktuellen Zustand der Infrastruktur. Diese Buchführung nennt sich State und ist eine der zentralen Komponenten von Terraform.

## Was steht im State?

Nach dem ersten `terraform apply` legt Terraform eine Datei namens `terraform.tfstate` an. Sie enthält im JSON-Format eine Zuordnung zwischen den Ressourcen in der Konfiguration und den tatsächlichen Objekten in der realen Welt, z.B. einer Azure-Ressourcen-ID. Ohne diese Zuordnung wüsste Terraform bei einem erneuten `apply` nicht, ob eine Ressource bereits existiert oder neu erstellt werden muss.

Der State enthält außerdem sämtliche Attribute der verwalteten Ressourcen, inklusive Werten, die gar nicht in der Konfiguration auftauchen, wie automatisch generierte IDs. Dadruch kann Terraform bei jedem Befehl vergleichen, ob sich der reale Zustand der Infrastruktur von dem im State gespeicherten Zustand unterscheidet.

Vereinfacht sieht eine `terraform.tfstate`-Datei für eine einzelne Resource Group etwa so aus:

```json
{
  "version": 4,
  "terraform_version": "1.12.1",
  "resources": [
    {
      "mode": "managed",
      "type": "azurerm_resource_group",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "attributes": {
            "id": "/subscriptions/xxxx/resourceGroups/rg-eigene-app",
            "name": "rg-eigene-app",
            "location": "westeurope"
          }
        }
      ]
    }
  ]
}
```

Man sieht hier gut das Prinzip: Jede Ressource aus der Konfiguration (`azurerm_resource_group.main`) taucht als eigener Eintrag auf, zusammen mit ihrer echten `id` in Azure und allen weiteren Attributen. Genau diese `id` nutzt Terraform, um bei einem erneuten `plan` den Ist- mit dem Soll-Zustand abzugleichen.

Das lauffähige Beispiel weiter unten nutzt zur Vereinfachung den `local`-Provider statt Azure - das Prinzip (Ressource → Eintrag im State mit `id` und Attributen) ist aber identisch.

## Warum der State wichtig ist

- **Mapping**: Der State verknüpft Ressourcen in der Konfiguration mit realen Objekten in der Cloud.
- **Performance**: Anstatt bei jedem Befehl den Zustand aller Ressourcen bei jedem Provider abzufragen, kann Terraform auf die im State gespeicherten Werte zurückgreifen.
- **Zusammenarbeit**: Wird der State remote gespeichert, können mehrere Personen mit derselben Konfiguration arbeiten, ohne sich gegenseitig zu überschreiben.

## Sensible Daten im State

Der State kann sensible Werte wie Passwörter oder Zugangsschlüssel im Klartext enthalten, auch wenn diese in der Konfiguration als `sensitive` markiert wurden. Die Datei sollte daher niemals in ein Git-Repository eingecheckt und stattdessen remote sowie verschlüsselt gespeichert werden.

## Remote State

Standardmäßig wird der State lokal im Projektordner abgelegt. Für die Zusammenarbeit im Team wird stattdessen ein sogenannter Remote Backend verwendet, z.B. ein Azure Storage Account. Konfiguriert wird dies über einen `backend`-Block:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name = "rg-terraform-state"
    storage_account_name = "sttfstateschulung"
    container_name       = "tfstate"
    key                  = "eigene-app.tfstate"
  }
}
```

Wichtig dabei ist das sogenannte State Locking: Während ein `apply` läuft, wird der State gesperrt, damit nicht gleichzeitig ein zweiter Prozess Änderungen vornimmt und den State korumpiert.

### Backend wechseln: -migrate-state und -reconfigure

Wird ein `backend`-Block neu hinzugefügt oder geändert (z.B. lokal → remote, oder ein anderer Storage Account), reicht ein einfaches `terraform init` nicht mehr aus - Terraform bemerkt, dass sich die Backend-Konfiguration geändert hat, und fragt interaktiv nach:

```text
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "local" backend. No existing state was found in the newly
  configured "local" backend. Do you want to copy this state to the new "local"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value:
```

Für nicht-interaktive Umgebungen (Skripte, CI/CD) oder um die eigene Absicht klar zu machen, gibt es zwei Flags für `terraform init`:

- **`-migrate-state`**: bestehenden State in das neue Backend mitnehmen. Live getestet: Nach `terraform init -migrate-state` (mit `yes` bestätigt) landet die vorher lokale Ressource tatsächlich im neuen Backend - `terraform state list` zeigt sie dort unverändert an.
- **`-reconfigure`**: Backend neu konfigurieren, ohne den alten State zu migrieren - man startet im neuen Backend bei null, der alte State bleibt unangetastet am alten Ort liegen.

⚠️ In diesem Kapitel läuft alles über den lokalen `local`-Provider. Ein Wechsel zwischen zwei lokalen Backend-Pfaden hat in eigenen Tests trotz beider Flags weiterhin interaktiv nachgefragt - die Flags ersetzen die Rückfrage hier nicht, sondern signalisieren vor allem die eigene Absicht, sobald man antwortet. Mit `-input=false` allein (egal mit welchem der beiden Flags) bricht `terraform init` in diesem Szenario live getestet konsequent ab: `Error: Can't ask approval for state migration when interactive input is disabled.` Für unbeaufsichtigte Pipelines bleibt dann nur, die Antwort vorab bereitzustellen, z.B. mit `yes | terraform init -migrate-state` - genau das habe ich getestet, es kopiert den State zuverlässig ins neue Backend. Deshalb arbeitet die [CI/CD-Pipeline](../../04-ci-cd/01-ci-cd-pipeline.md) in diesem Kurs von Anfang an mit einem leeren Backend statt nachträglich zu migrieren - das umgeht dieses ganze Thema komplett.

## Nützliche Befehle

```bash
terraform state list           # Zeigt alle Ressourcen im State an
terraform show                  # Zeigt den aktuellen State im Detail an
terraform state mv <a> <b>      # Verschiebt/benennt eine Ressource im State um
terraform state rm <addr>       # Entfernt eine Ressource aus dem State, ohne sie zu löschen
terraform apply -refresh-only   # Zeigt Drift zwischen State und Realität, ohne etwas zu ändern
terraform import <addr> <id>    # Übernimmt eine bereits existierende Ressource in den State
```

Der State sollte nur über diese Befehle oder durch `apply`/`destroy` verändert werden. Manuelles Bearbeiten der `terraform.tfstate`-Datei kann den State inkonsistent machen und sollte vermieden werden.

## Selbst ausprobieren

In diesem Ordner liegt ein minimales Beispiel mit dem `local`-Provider. Der `apply` dauert dort absichtlich ca. 15 Sekunden (über eine `time_sleep`-Ressource), damit genug Zeit bleibt, den State Lock live zu beobachten.

### Schritt 1: State Lock live sehen

Zuerst in einem ersten Terminal den Apply starten:

```bash
terraform init
terraform apply
```

Während der Apply noch läuft, in einem zweiten Terminal im selben Ordner `terraform plan` ausführen. Da der State gerade durch den ersten Prozess gesperrt ist, meldet Terraform einen Fehler ähnlich diesem:

```text
Error: Error acquiring the state lock

Error message: resource temporarily unavailable
Lock Info:
  ID:        ...
  Path:      terraform.tfstate
  Operation: OperationTypeApply
  Who:       ...
```

Sobald der erste `apply` fertig ist, gibt der zweite Befehl den Lock automatisch wieder frei und weitere Befehle funktionieren wie gewohnt.

### Schritt 2: Die State-Datei ansehen

Nach dem `apply` lohnt sich ein Blick in die entstandene `terraform.tfstate` sowie die oben genannten Befehle:

```bash
cat terraform.tfstate
terraform state list
terraform show
```

### Schritt 3: Sensible Werte im State

Das Beispiel enthält außerdem eine Variable `api_key`, die als `sensitive = true` markiert ist. Terraform blendet solche Werte in der Konsole konsequent aus:

```bash
terraform output              # zeigt "api_key = <sensitive>"
terraform plan                # zeigt bei Änderungen "(sensitive value)" statt des echten Werts
```

Schaut man aber direkt in die State-Datei, steht der Wert trotzdem im Klartext drin:

```bash
grep api_key terraform.tfstate
```

Das bestätigt die Warnung von weiter oben: `sensitive = true` schützt nur die CLI-Ausgabe, nicht den Inhalt des States. Wer echte Secrets verwaltet, kommt daher nicht darum herum, den State selbst zu schützen (verschlüsseltes Remote Backend, Zugriffsbeschränkungen) statt sich allein auf das `sensitive`-Flag zu verlassen.

### Schritt 4: State verschieben

Wird eine Ressource im Code umbenannt, kennt Terraform den Zusammenhang zum alten Namen nicht automatisch - es sieht nur, dass die alte Adresse aus der Konfiguration verschwunden und eine neue aufgetaucht ist. Benennt `local_file.example` in `main.tf` zu `local_file.app` um (nur den Ressourcennamen, `filename` bleibt `example.txt`):

```bash
terraform plan
```

```text
  # local_file.app will be created
  + resource "local_file" "app" {
      ...
    }

  # local_file.example will be destroyed
  # (because local_file.example is not in configuration)
  - resource "local_file" "example" {
      ...
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Ohne Eingreifen würde Terraform die Datei also komplett neu anlegen, obwohl sich inhaltlich nichts geändert hat - bei einer echten Cloud-Ressource wäre das im schlimmsten Fall ein ungewollter Downtime. Die saubere Lösung ist `terraform state mv`, das dem State-Eintrag einfach eine neue Adresse gibt, ohne die reale Ressource anzufassen:

```bash
terraform state mv local_file.example local_file.app
```

```text
Move "local_file.example" to "local_file.app"
Successfully moved 1 object(s).
```

```bash
terraform plan
```

```text
No changes. Your infrastructure matches the configuration.
```

Ab hier heißt die Ressource im Beispiel `local_file.app` - die folgenden Schritte bauen darauf auf.

Zum selbst Üben statt Nachvollziehen: [Playground-Aufgabe 6](../../playground/06-state-reparatur/AUFGABE.md).

### Schritt 5: State fixen - Drift erkennen und beheben

"Drift" bedeutet, dass sich die reale Welt und der State auseinanderentwickelt haben, z.B. weil jemand manuell an einer Ressource vorbei am Terraform gearbeitet hat. Simuliert das, indem ihr die erzeugte Datei direkt bearbeitet, statt über Terraform:

```bash
echo "Manuell geändert, an Terraform vorbei." > example.txt
```

Mit `terraform apply -refresh-only` lässt sich Drift anzeigen, ohne dass Terraform sofort etwas dagegen unternimmt:

```bash
terraform apply -refresh-only
```

```text
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply" which may have affected this plan:

  # local_file.app has been deleted
  - resource "local_file" "app" {
      ...
    }

This is a refresh-only plan, so Terraform will not take any actions to undo
these. If you were expecting these changes then you can apply this plan to
...
```

Bei `local_file` erscheint eine inhaltliche Änderung von außen als "has been deleted", weil die `id` der Ressource ein Hash des Inhalts ist - ändert sich der Inhalt, findet Terraform beim Nachschauen nicht mehr das erwartete Objekt. Ein normaler `apply` bringt die Datei wieder in Einklang mit der Konfiguration:

```bash
terraform apply
```

Manchmal soll Terraform eine Ressource aber gar nicht mehr verwalten, ohne sie zu löschen - z.B. weil sie an ein anderes Team übergeben wird. Dafür gibt es `terraform state rm`:

```bash
terraform state rm local_file.app
```

```text
Removed local_file.app
Successfully removed 1 resource instance(s).
```

Wichtig: Die Datei existiert danach immer noch (`ls example.txt` zeigt sie weiterhin) - `state rm` löscht nur den Eintrag aus der Buchführung, nicht die reale Ressource. `terraform state list` zeigt `local_file.app` jetzt nicht mehr an. Ein erneuter `apply` würde die Datei als neue Ressource wieder in den State aufnehmen (mit identischem Inhalt landet sie dabei praktisch unverändert auf der Platte).

### Schritt 6: Kaputten State retten

Zuletzt der Ernstfall: Die `terraform.tfstate`-Datei selbst ist beschädigt, z.B. durch einen abgebrochenen Prozess oder einen fehlerhaften manuellen Eingriff. Terraform legt bei jedem `apply`, der den State ändert, automatisch eine Sicherung `terraform.tfstate.backup` an (die jeweils vorherige Version, wird bei jedem Lauf überschrieben).

Nach Schritt 5 ist `local_file.app` durch `state rm` nicht mehr im State - das erst einmal rückgängig machen, ein normaler `apply` nimmt die (unverändert vorhandene) Datei wieder auf:

```bash
terraform apply
```

Für einen garantiert sauberen, bekannten Ausgangspunkt jetzt einmal gezielt `-replace` nutzen (siehe [Replace und Lifecycle](../08-replace-und-lifecycle/00-replace-und-lifecycle.md)):

```bash
terraform apply -replace="local_file.app"
```

```text
Plan: 1 to add, 0 to change, 1 to destroy.
local_file.app: Destroying...
local_file.app: Creating...
local_file.app: Creation complete after 0s

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

Damit existieren jetzt sowohl `terraform.tfstate` als auch eine ganz frische `terraform.tfstate.backup` mit demselben Inhalt. Jetzt die State-Datei absichtlich beschädigen:

```bash
echo "{ das ist kein gültiges JSON" > terraform.tfstate
terraform plan
```

```text
Error: Error acquiring the state lock

Error message: 2 problems:

- Unsupported state file format: The state file could not be parsed as JSON:
syntax error at byte offset 3.
- Unsupported state file format: The state file does not have a "version"
attribute, which is required to identify the format version.
```

Terraform kommt an dieser Stelle nicht mehr weiter - ohne lesbaren State weiß es nicht, was existiert. Die Rettung ist die automatische Sicherung:

```bash
cp terraform.tfstate.backup terraform.tfstate
terraform plan
```

```text
No changes. Your infrastructure matches the configuration.
```

Das `.backup`-Verfahren rettet euch dabei nur vor dem *zuletzt* geschriebenen Stand - geht mehr als eine Änderung verloren, kann ein nachfolgender `plan` durchaus noch Differenzen zur allerneuesten Änderung zeigen (dann hilft nur, diese eine Änderung erneut anzuwenden). Bei `terraform state mv` und `terraform state rm` legt Terraform übrigens zusätzlich eigene, zeitgestempelte Sicherungen an (`terraform.tfstate.<timestamp>.backup`) - auch die lassen sich im Notfall genauso zurückkopieren.

Bei einem Remote Backend (siehe oben) übernimmt der jeweilige Speicherort meist eigene Mechanismen dafür (z.B. Versionierung bei einem Azure Storage Account) - trotzdem schadet es nicht, das Prinzip einmal lokal gesehen zu haben.

Zum eigenständigen Üben von `state mv` an einem neuen Beispiel (statt der Schritt-für-Schritt-Anleitung oben zu wiederholen): [Playground-Aufgabe 6](../../playground/06-state-reparatur/AUFGABE.md).
