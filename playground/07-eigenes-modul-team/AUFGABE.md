# Aufgabe 7: Duplizierten Code zum Modul machen

**Thema:** Module - die Grundmechanik nochmal (siehe [Module erweitert](../../01-grundlagen/07-module-erweitert/00-module-erweitert.md))

`main.tf` enthält drei `local_file`-Ressourcen, die strukturell komplett identisch sind - nur `projekt` und `status` unterscheiden sich. Genau das Problem, das der Kapiteltext auch zeigt. Eure Aufgabe: baut daraus ein Modul.

**Schritte:**

1. Legt `modules/projektstatus/` an mit `variables.tf` (Variablen `projekt`, `status`, `output_dir`), `main.tf` (die `local_file`-Ressource) und `outputs.tf` (Output `pfad`).
2. Ersetzt die drei Ressourcen in `main.tf` durch drei `module`-Blöcke, die dieses Modul mit den passenden Werten aufrufen.

**Ziel:** Das Ergebnis (drei Dateien mit demselben Inhalt wie vorher) soll identisch bleiben - nur der Weg dorthin ändert sich.

## Testen

```bash
terraform init
terraform apply
ls output/
terraform state list
```

`terraform state list` sollte jetzt `module.<name>.local_file.status` statt `local_file.status_<name>` zeigen.

## Aufräumen

```bash
terraform destroy
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
