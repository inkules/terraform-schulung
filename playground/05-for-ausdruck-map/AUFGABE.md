# Aufgabe 5: for-Ausdruck über eine Map

**Thema:** for-Ausdrücke (siehe [Schleifen, Bedingungen und Collections](../../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md))

In `variables.tf` steht eine Map mit Nettopreisen (`var.preise_netto`, `map(number)`). Eure Aufgabe: Baut in `main.tf` einen for-Ausdruck (in einem `locals`-Block), der daraus eine neue Map `preise_brutto` macht - jeder Preis um 19% erhöht. Schlüssel bleiben gleich, nur die Werte ändern sich. Gebt das Ergebnis über einen Output `preise_brutto` aus.

**Hinweis:** Hier entsteht keine einzige Ressource - reine Werte-Transformation, genau wie im Kapiteltext.

⚠️ **Stolperfalle:** `preis * 1.19` direkt ausgeben kann zu hässlichen, langen Fließkommazahlen führen (HCL-Zahlenarithmetik). Rundet sauber auf zwei Nachkommastellen, z.B. mit `format("%.2f", ...)`.

## Testen

```bash
terraform init
terraform apply
```

`preise_brutto` sollte für jedes Produkt einen sauber gerundeten Bruttopreis zeigen.

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
