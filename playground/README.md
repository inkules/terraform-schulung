# Playground

Acht kleine, in sich abgeschlossene Zusatzaufgaben zum aktiven Üben - unabhängig von den "Selbst ausprobieren"-Beispielen in den Kapiteln, die vorgeben, was am Ende rauskommt. Hier bekommt ihr einen Ausgangspunkt (Variablen, manchmal ein Gerüst mit TODOs) und müsst den Rest selbst bauen. Jede Aufgabe hat eine eigene, getestete Lösung zum Vergleichen - aber erst selbst versuchen, das ist der Punkt der Übung.

| # | Aufgabe | Thema | Bezug |
| --- | --- | --- | --- |
| 01 | [Eigene Variable](01-eigene-variable/AUFGABE.md) | `variable`-Block, String-Interpolation | [Variablen in Terraform](../01-grundlagen/03-variablen-und-dateien/00-variablen-und-dateien.md) |
| 02 | [for_each über Teammitglieder](02-for-each-teammitglieder/AUFGABE.md) | `for_each`, `toset()` | [Schleifen, Bedingungen und Collections](../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md) |
| 03 | [Bedingte Ressource](03-bedingte-ressource/AUFGABE.md) | Bedingter Ausdruck, `count` | [Schleifen, Bedingungen und Collections](../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md) |
| 04 | [Eigenes Modul](04-eigenes-modul/AUFGABE.md) | Module, `path.root` vs. `path.module` | [Module und Outputs](../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md) |
| 05 | [for-Ausdruck über eine Map](05-for-ausdruck-map/AUFGABE.md) | for-Ausdrücke, Zahlenrundung | [Schleifen, Bedingungen und Collections](../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md) |
| 06 | [State-Reparatur](06-state-reparatur/AUFGABE.md) | `terraform state mv` | [Der Terraform State](../01-grundlagen/04-state/00-state.md) |
| 07 | [Duplizierten Code zum Modul machen](07-eigenes-modul-team/AUFGABE.md) | Module - die Grundmechanik | [Module erweitert](../01-grundlagen/07-module-erweitert/00-module-erweitert.md) |
| 08 | [Outputs](08-outputs/AUFGABE.md) | Output-Blöcke, `sensitive` | [Module und Outputs](../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md) |

Alle Aufgaben laufen mit dem `local`-Provider - kein Cloud-Zugang nötig. Jede Aufgabe lässt sich unabhängig von den anderen bearbeiten, in beliebiger Reihenfolge - am meisten Sinn ergeben sie aber, nachdem das jeweils verlinkte Kapitel durchgearbeitet wurde.
