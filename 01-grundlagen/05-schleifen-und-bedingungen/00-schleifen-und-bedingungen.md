# Schleifen, Bedingungen und Collections

HCL ist keine vollwertige Programmiersprache, bietet aber einige mächtige Konstrukte, um Konfigurationen dynamisch statt starr zu schreiben: Schleifen über Ressourcen, bedingte Werte und Ausdrücke zum Umformen von Listen und Maps. Dieses Kapitel ist etwas komplexer als die vorherigen, lohnt sich aber, da diese Konstrukte in nahezu jedem realen Terraform-Projekt auftauchen. Jedes Konzept hat hier sein eigenes, kleines Beispiel zum Ausprobieren, statt eines großen Beispiels für alles auf einmal.

## Collections: List, Set und Map

Neben einfachen Typen wie `string`, `number` und `bool` kennt HCL drei Sammlungs-Typen, die die Grundlage für Schleifen bilden:

- **List** (`list(string)`): eine geordnete Sammlung, Duplikate sind erlaubt. Zugriff über den Index, z.B. `var.meine_liste[0]`.
- **Set** (`set(string)`): eine ungeordnete Sammlung ohne Duplikate. Wird häufig für `for_each` verwendet, da die Reihenfolge dort keine Rolle spielt.
- **Map** (`map(string)`): eine Sammlung von Key-Value-Paaren, ähnlich einem Dictionary. Zugriff über den Schlüssel, z.B. `var.meine_map["key"]`.

Als Running-Beispiel für dieses Kapitel bekommt jede Umgebung ihren eigenen Pizzabelag - für `prod` ist absichtlich kein Belag hinterlegt, das wird später im Kapitel wichtig:

```hcl
variable "umgebungen" {
  type    = set(string)
  default = ["dev", "staging", "prod"]
}

variable "pizza_je_umgebung" {
  type = map(string)
  default = {
    dev     = "Salami"
    staging = "Peperoni"
    # "prod" hat bewusst keinen Eintrag
  }
}
```

## count: Ressourcen wiederholen

Mit dem Meta-Argument `count` lässt sich eine Ressource mehrfach erstellen. Innerhalb der Ressource steht dabei `count.index` (beginnend bei 0) zur Verfügung:

```hcl
variable "anzahl_logs" {
  type    = number
  default = 3
}

resource "local_file" "log" {
  count    = var.anzahl_logs
  filename = "${path.module}/output/log-${count.index}.txt"
  content  = "Log-Eintrag Nummer ${count.index}"
}
```

`count` eignet sich gut für einfache, gleichartige Wiederholungen. Sobald sich die einzelnen Instanzen aber inhaltlich unterscheiden sollen (z.B. je Umgebung ein anderer Name), ist `for_each` meist die bessere Wahl - siehe nächster Abschnitt.

**Selbst ausprobieren:** [`01-count/`](01-count/)

```bash
cd 01-count
terraform init
terraform apply
```

Danach liegen im Ordner `output/` drei Dateien `log-0.txt` bis `log-2.txt`. Ändert `anzahl_logs` per `-var="anzahl_logs=5"` und beobachtet, wie sich die Anzahl der Dateien anpasst.

## for_each: über Sets und Maps iterieren

`for_each` iteriert über ein Set oder eine Map und erstellt für jeden Eintrag eine eigene Instanz der Ressource. Innerhalb der Ressource steht `each.key` und `each.value` zur Verfügung:

```hcl
resource "local_file" "pro_umgebung" {
  for_each = var.umgebungen

  filename = "${path.module}/output/${each.value}.txt"
  content  = "Umgebung: ${each.value}\nPizza: ${lookup(var.pizza_je_umgebung, each.value, "Margherita")}"
}
```

Die Funktion `lookup(map, key, default)` holt hier den Belag zum aktuellen Set-Eintrag aus `var.pizza_je_umgebung`. Für `dev` und `staging` steht dort ein Eintrag, der wird direkt zurückgegeben. Für `prod` gibt es in der Map oben bewusst **keinen** Eintrag - `lookup()` greift dann auf das dritte Argument zurück, den Default-Wert `"Margherita"`. Deshalb landet in `output/prod.txt` am Ende `Pizza: Margherita`, obwohl `"Margherita"` nirgendwo für `prod` konfiguriert wurde. Ohne dieses dritte Argument würde `lookup()` für fehlende Schlüssel stattdessen einen Fehler werfen.

Ein großer Vorteil gegenüber `count`: Wird ein Element aus dem Set entfernt, löscht Terraform gezielt nur die dazugehörige Ressource. Bei `count` hingegen würde sich der Index aller nachfolgenden Elemente verschieben, was zu unnötigen Neu-Erstellungen führen kann.

**Selbst ausprobieren:** [`02-for-each/`](02-for-each/)

```bash
cd 02-for-each
terraform init
terraform apply
```

Im Ordner `output/` landet für jede Umgebung eine eigene Datei mit dem passenden Pizzabelag im Inhalt. Ein Blick in `output/prod.txt` zeigt den Fallback in Aktion: `Pizza: Margherita`, obwohl `prod` in `pizza_je_umgebung` gar nicht vorkommt.

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 2](../../playground/02-for-each-teammitglieder/AUFGABE.md).

## toset()

`for_each` akzeptiert nur `set` oder `map` - keine `list`. Das Beispiel oben hat das umgangen, indem `var.umgebungen` von Anfang an als `set(string)` deklariert ist. Kommt der Ausgangswert aber als `list(string)` daher, braucht es die Funktion `toset()`:

```hcl
variable "usernames" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

resource "local_file" "nutzer" {
  for_each = toset(var.usernames)
  filename = "${path.module}/output/${each.value}.txt"
  content  = "Nutzer: ${each.value}"
}
```

Ohne `toset()` bricht Terraform schon bei `validate` ab, live getestet: *"The given `for_each` argument value is unsuitable: the `for_each` argument must be a map, or set of strings, and you have provided a value of type list of string."* Bei einem aus einer Liste erzeugten Set gilt außerdem: `each.key == each.value` - es gibt keinen separaten Schlüssel wie bei einer Map, deshalb landet in eckigen Klammern der String selbst, z.B. `local_file.nutzer["alice"]`.

## Bedingte Ausdrücke

HCL kennt keine klassische `if`-Anweisung, aber einen bedingten Ausdruck (Ternary-Operator) nach dem Muster `Bedingung ? Wert_wenn_wahr : Wert_wenn_falsch`:

```hcl
variable "erstelle_backup" {
  type    = bool
  default = true
}

resource "local_file" "backup" {
  count    = var.erstelle_backup ? 1 : 0
  filename = "${path.module}/output/backup.txt"
  content  = "Backup-Datei"
}
```

Ist `erstelle_backup` auf `false` gesetzt, wird `count` zu `0` und die Ressource entsprechend gar nicht erstellt.

**Selbst ausprobieren:** [`03-bedingungen/`](03-bedingungen/)

```bash
cd 03-bedingungen
terraform init
terraform apply                                  # erstellt backup.txt
terraform apply -var="erstelle_backup=false"     # löscht backup.txt wieder
```

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 3](../../playground/03-bedingte-ressource/AUFGABE.md).

## for-Ausdrücke

Mit einem for-Ausdruck lassen sich Listen und Maps umformen, ohne dabei eine Ressource zu erstellen. Das ist praktisch, um z.B. Werte vorzubereiten, die anschließend an eine Ressource oder ein Modul übergeben werden:

```hcl
locals {
  umgebungen_gross = [for u in var.umgebungen : upper(u)]

  pizza_gross = {
    for umgebung, pizza in var.pizza_je_umgebung :
    umgebung => upper(pizza)
  }
}
```

Das erste Beispiel erzeugt aus der Liste der Umgebungen eine neue Liste mit Großbuchstaben, das zweite tut dasselbe für die Werte einer Map, behält dabei aber die Schlüssel bei.

**Selbst ausprobieren:** [`04-for-ausdruecke/`](04-for-ausdruecke/)

Dieses Beispiel erstellt bewusst keine einzige Ressource - for-Ausdrücke sind reine Werte-Transformationen, das lässt sich komplett über Outputs beobachten:

```bash
cd 04-for-ausdruecke
terraform init
terraform apply
```

```text
Outputs:

pizza_gross = {
  "dev" = "SALAMI"
  "prod" = "MARGHERITA"
  "staging" = "PEPERONI"
}
umgebungen_gross = [
  "DEV",
  "PROD",
  "STAGING",
]
```

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 5](../../playground/05-for-ausdruck-map/AUFGABE.md).

Zum selbst Bauen statt Nachvollziehen: [Playground-Aufgabe 5](../../playground/05-for-ausdruck-map/AUFGABE.md).
