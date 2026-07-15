# Aufgabe 1: Eigene Variable

**Thema:** Variablen (siehe [Variablen in Terraform](../../01-grundlagen/03-variablen-und-dateien/00-variablen-und-dateien.md))

In `main.tf` liegt eine `local_file`-Ressource mit fest eingebautem Text. Eure Aufgabe:

1. Ergänzt eine Variable `autor` (`type = string`) mit einem Default eurer Wahl.
2. Baut sie per String-Interpolation in `content` ein, z.B. `"Diese Notiz wurde erstellt von ${var.autor}."`.

## Testen

```bash
terraform init
terraform apply
cat notiz.txt
```

Der Inhalt von `notiz.txt` sollte euren Namen enthalten. Zum Ausprobieren: `terraform apply -var="autor=Jemand anderes"` und schauen, was sich ändert.

## Aufräumen

```bash
terraform destroy
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
