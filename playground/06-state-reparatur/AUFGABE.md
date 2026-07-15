# Aufgabe 6: State-Reparatur

**Thema:** `state mv` (siehe [Der Terraform State](../../01-grundlagen/04-state/00-state.md))

Anders als die anderen Aufgaben hier: keine neue Syntax schreiben, sondern einen State-Workflow üben.

1. `main.tf` enthält eine Ressource `local_file.eintrag`. Erst mal ganz normal anwenden:

   ```bash
   terraform init
   terraform apply
   ```

2. Benennt in `main.tf` den Ressourcennamen von `eintrag` zu `datensatz` um (nur das Label, **nicht** `filename`).

3. Schaut euch `terraform plan` an. Was schlägt Terraform vor? Warum?

4. Repariert das *ohne* die Datei neu erstellen zu lassen - mit `terraform state mv`.

5. Verifiziert mit `terraform plan`, dass danach wirklich nichts mehr geändert werden muss.

## Aufräumen

```bash
terraform destroy
```

Lösung (als Schritt-für-Schritt-Transkript mit echtem Output) liegt in [`loesung/LOESUNG.md`](loesung/LOESUNG.md), aber erst selbst versuchen!
