# Lösung: State-Reparatur

Live getestet, exakter Ablauf:

```bash
cd playground/06-state-reparatur
terraform init
terraform apply    # local_file.eintrag wird erstellt
```

Jetzt in `main.tf` den Ressourcennamen von `eintrag` zu `datensatz` ändern (nur das Label, nicht `filename`):

```hcl
resource "local_file" "datensatz" {
  filename = "${path.module}/eintrag.txt"
  content  = "Wichtiger Eintrag - bitte nicht neu erstellen lassen."
}
```

Ohne Eingreifen plant Terraform jetzt Löschen + Neuanlegen, weil es den Zusammenhang zum alten Namen nicht kennt:

```bash
terraform plan
```

```text
  - resource "local_file" "eintrag" {
      - content  = "Wichtiger Eintrag - bitte nicht neu erstellen lassen." -> null
      - filename = "./eintrag.txt" -> null
      ...
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Die saubere Reparatur - State-Eintrag umbenennen statt Ressource neu erstellen:

```bash
terraform state mv local_file.eintrag local_file.datensatz
```

```text
Move "local_file.eintrag" to "local_file.datensatz"
Successfully moved 1 object(s).
```

Verifizieren:

```bash
terraform plan
```

```text
No changes. Your infrastructure matches the configuration.
```

Aufräumen:

```bash
terraform destroy
```
