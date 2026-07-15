# TODO: Baut einen for-Ausdruck (in einem locals-Block), der aus
# var.preise_netto eine neue Map "preise_brutto" macht - jeder Preis um
# 19% erhöht (also mit 1.19 multipliziert). Schlüssel bleiben gleich,
# nur die Werte ändern sich. Gebt das Ergebnis über einen Output "preise_brutto"
# aus. Hinweis: Hier entsteht keine einzige Ressource - reine Werte-Transformation.
#
# Stolperfalle: preis * 1.19 direkt ausgeben kann zu hässlichen, langen
# Fließkommazahlen führen (HCL-Zahlenarithmetik). Rundet sauber auf zwei
# Nachkommastellen, z.B. mit format("%.2f", ...).
