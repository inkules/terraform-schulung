# Aufgabe 2: for_each über Teammitglieder

**Thema:** `for_each`, `toset()` (siehe [Schleifen, Bedingungen und Collections](../../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md))

In `variables.tf` steht eine Liste von Teammitgliedern (`var.team`, `list(string)`). In `main.tf` steht bereits das Gerüst einer `local_file`-Ressource, die für jedes Teammitglied eine eigene Datei erzeugt - euch fehlt nur noch das `for_each`-Argument.

**Anforderung:** `for_each` akzeptiert kein `list` - was müsst ihr tun, damit es funktioniert?

## Testen

```bash
terraform init
terraform apply
ls output/
```

Es sollten drei Dateien entstehen (mira.txt, jonas.txt, priya.txt). Zum Ausprobieren: ein Name in `variables.tf` hinzufügen/entfernen und `apply` wiederholen - schaut euch an, welche Datei sich ändert.

## Aufräumen

```bash
terraform destroy
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
