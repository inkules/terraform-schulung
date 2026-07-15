# Aufgabe 4: Eigenes Modul

**Thema:** Module (siehe [Module und Outputs](../../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md))

`main.tf` ruft bereits ein Modul `./modules/gruss` zweimal auf, mit unterschiedlichen Namen (`Mira`, `Jonas`). Das Modul selbst existiert aber nur als Gerüst mit TODOs - eure Aufgabe: baut es fertig.

In `modules/gruss/`:
- **`variables.tf`**: eine Variable `name` (`type = string`).
- **`main.tf`**: eine `local_file`-Ressource `gruss`, die `output/<name>-gruss.txt` mit Inhalt `"Hallo, <name>! Willkommen im Kurs."` erzeugt.
- **`outputs.tf`**: ein Output `pfad` mit dem Dateipfad.

⚠️ **Stolperfalle:** Das Modul wird zweimal mit derselben `source` aufgerufen. `path.module` würde für beide Instanzen auf denselben physischen Ordner zeigen - Dateikonflikt! Nutzt stattdessen `path.root` (zeigt auf den aufrufenden Root-Ordner) und baut `var.name` mit in den Dateinamen ein.

## Testen

```bash
terraform init
terraform apply
terraform output gruss_pfade
ls output/
```

Es sollten zwei unterschiedliche Dateien entstehen, keine Kollision.

## Aufräumen

```bash
terraform destroy
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
