# Aufgabe 3: Bedingte Ressource

**Thema:** Bedingte Ausdrücke, `count` (siehe [Schleifen, Bedingungen und Collections](../../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md))

In `variables.tf` steht eine Bool-Variable `produktion`. Eure Aufgabe: Baut in `main.tf` eine `local_file`-Ressource `debug`, die eine Datei `debug.txt` mit Inhalt `"Debug-Modus aktiv"` erzeugt - aber **nur**, wenn `var.produktion = false` ist. In Produktion soll die Datei gar nicht existieren.

**Hinweis:** bedingter Ausdruck (`Bedingung ? a : b`) kombiniert mit `count`.

## Testen

```bash
terraform init
terraform apply                       # produktion=false (Default) -> Datei entsteht
ls debug.txt

terraform apply -var="produktion=true" # Datei sollte wieder verschwinden
ls debug.txt   # sollte "No such file" melden
```

## Aufräumen

```bash
terraform destroy -var="produktion=true"
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
