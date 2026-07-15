# Hasicorp Language Configuration (HCL)

HCL ist eine deklarative Konfigurationssprache welche von HashiCorp entwickelt wurde. Sie wird neben Terraform auch in anderen HashiCorp-Produkten wie Consul, Vault oder Noman genutzt.
HCL wurde mit dem Ansatz entwickelt, dass es sowohl für Menschen lesbar als auch für Maschinen verarbeitbar ist. Die Syntax von HCL ist einfach und intuitiv, was es Entwicklern erleichtert, Infrastrukturressourcen zu definieren und zu verwalten.

## Blöcke, Attribute und Werte

Die grundlegende Struktur einer HCL-Konfiguration besteht aus Blöcken, Attributen und Werten. Blöcke werden durch geschweifte Klammern `{}` definiert und können verschachtelt sein. Attribute sind Key-Value-Paare, die innerhalb von Blöcken definiert werden.

Beispiel für eine einfache HCL-Konfiguration:

```hcl
resource "local_file" "greeting" {
  filename = "${path.module}/greeting.txt"
  content  = "Hallo Terraform!"
}
```

Hier ist `resource` das Blockschlüsselwort, `"local_file"` der Ressourcentyp, `"greeting"` der frei wählbare Name innerhalb der Konfiguration, und `filename`/`content` sind Attribute mit ihren jeweiligen Werten.

## Datentypen

Attribute und Variablen haben in HCL einen Typ. Die wichtigsten:

- **Primitive Typen**: `string` (Text), `number` (Zahl), `bool` (`true`/`false`)
- **Collection-Typen**: `list(...)` (geordnete Liste), `map(...)` (Key-Value-Paare)

```hcl
variable "name" {
  type    = string
  default = "Terraform"
}

variable "fun_facts" {
  type = list(string)
  default = [
    "HCL steht für HashiCorp Configuration Language",
    "Terraform speichert seinen Zustand im State",
  ]
}
```

Mehr zu Listen, Maps und Sets gibt es vertieft in [Schleifen, Bedingungen und Collections](../05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md) - an dieser Stelle reicht es zu wissen, dass es sie gibt und wie man sie deklariert.

## String-Interpolation

Werte anderer Variablen oder Ausdrücke lassen sich mit `${...}` direkt in einen String einsetzen, statt ihn manuell zusammenzubauen:

```hcl
filename = "${path.module}/greeting.txt"
content  = "Hallo, ${var.name}!"
```

`path.module` ist dabei ein eingebauter Verweis auf den Ordner, in dem die aktuelle `.tf`-Datei liegt - so funktioniert der Pfad unabhängig davon, von wo aus `terraform` aufgerufen wird. `var.name` liest den Wert der gleichnamigen Variable.

## Funktionen

HCL bringt eine Reihe eingebauter Funktionen mit, die sich wie überall sonst aufrufen lassen: `funktionsname(argument1, argument2, ...)`. Zwei Beispiele, die im Übungsordner dieses Kapitels verwendet werden:

- `upper(string)` - wandelt einen String in Großbuchstaben um.
- `join(trennzeichen, liste)` - fügt die Elemente einer Liste zu einem einzigen String zusammen, getrennt durch das übergebene Zeichen.

```hcl
upper("Hallo, Terraform!")               # -> "HALLO, TERRAFORM!"
join("\n", ["Zeile 1", "Zeile 2"])        # -> "Zeile 1\nZeile 2"
```

Die vollständige Liste aller eingebauten Funktionen steht in der [Terraform-Funktionsreferenz](https://developer.hashicorp.com/terraform/language/functions).

## Das Beispiel im Detail

Der Übungsordner (siehe unten) kombiniert alle bisherigen Bausteine zu einer generierten Begrüßungsdatei. So spielen die vier Dateien zusammen:

1. **`variables.tf`** deklariert zwei Eingaben: `var.name` (ein `string`) und `var.fun_facts` (ein `list(string)`).
2. **`locals.tf`** verarbeitet diese Eingaben weiter:

   ```hcl
   locals {
     greeting = upper("Hallo, ${var.name}!")
     facts    = join("\n", var.fun_facts)
   }
   ```

   `local.greeting` baut per String-Interpolation einen Satz und macht ihn per `upper()` komplett groß. `local.facts` fügt die Liste `var.fun_facts` per `join()` zu einem mehrzeiligen String zusammen.
3. **`main.tf`** nutzt beide `locals`, um den Inhalt einer Datei zusammenzusetzen:

   ```hcl
   resource "local_file" "greeting" {
     filename = "${path.module}/greeting.txt"
     content  = "${local.greeting}\n\n${local.facts}\n"
   }
   ```

4. **`outputs.tf`** gibt `local.greeting` zusätzlich als Output aus, damit er auch ohne Blick in die erzeugte Datei direkt in der Konsole sichtbar ist.

Nach `terraform apply` sieht die erzeugte `greeting.txt` so aus:

```text
HALLO, TERRAFORM!

HCL steht für HashiCorp Configuration Language
Terraform speichert seinen Zustand im State
```

## Selbst ausprobieren

Das komplette, lauffähige Beispiel liegt direkt in diesem Ordner. Es verwendet den `local`-Provider und kann direkt mit `terraform init` und `terraform apply` ausgeführt werden, ganz ohne Cloud-Zugang:

```bash
terraform init
terraform apply
cat greeting.txt
terraform output
```

Zum Ausprobieren lohnt es sich, `var.name` oder `var.fun_facts` in `variables.tf` zu ändern (oder per `-var` zu überschreiben, siehe nächstes Kapitel) und den `apply` erneut laufen zu lassen - so wird direkt sichtbar, wie sich Änderungen an den Variablen über `locals` bis in die generierte Datei durchziehen.

Der `locals`-Block steckt dort bewusst in einer eigenen `locals.tf` statt in der `main.tf`. Das ist keine technische Notwendigkeit - Terraform liest ohnehin alle `.tf`-Dateien im Ordner ein -, aber eine verbreitete Konvention, um berechnete Werte von den eigentlichen Ressourcen zu trennen.
