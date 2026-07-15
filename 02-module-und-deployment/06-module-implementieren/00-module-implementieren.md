# Module implementieren

Im Grundlagen-Kapitel [Module und Outputs](../../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md) habt ihr die Mechanik eines Moduls kennengelernt: Variablen rein, Outputs raus, einmal aufgerufen. Für echtes Skalieren fehlt noch ein Baustein: ein Modul **mehrfach** aufzurufen, ohne den `module`-Block zu kopieren. Genau das macht `for_each` auf einem `module`-Block möglich - die konsequente Fortsetzung von [Weg von Copy & Paste](../05-weg-von-copy-paste/00-weg-von-copy-paste.md).

## Ein Modul mehrfach aufrufen

Genau wie bei einer Ressource lässt sich auch ein `module`-Block mit `for_each` versehen. Terraform erstellt dann pro Eintrag der übergebenen Map eine eigene, komplette Modul-Instanz:

```hcl
locals {
  umgebungen = {
    dev     = { sku = "B1", instance_count = 1 }
    staging = { sku = "B2", instance_count = 2 }
    prod    = { sku = "P1v2", instance_count = 3 }
  }
}

module "webapp" {
  for_each = local.umgebungen

  source         = "./modules/webapp"
  name           = each.key
  sku            = each.value.sku
  instance_count = each.value.instance_count
}
```

Eine vierte Umgebung hinzuzufügen bedeutet ab jetzt: eine weitere Zeile in `local.umgebungen`. Kein neuer `module`-Block, kein kopierter Ordner, keine zusätzliche Datei.

## Adressierung: aus einem Modul wird eine Map von Modulen

Sobald ein `module`-Block `for_each` verwendet, ist `module.webapp` nicht mehr eine einzelne Modul-Instanz, sondern eine Map aus Instanzen - genau wie bei `for_each` auf Ressourcen. Der Zugriff auf eine einzelne Instanz läuft über den Schlüssel:

```hcl
module.webapp["dev"].config_path
```

Um Werte über alle Instanzen hinweg einzusammeln, eignet sich ein for-Ausdruck (siehe [Schleifen, Bedingungen und Collections](../../01-grundlagen/05-schleifen-und-bedingungen/00-schleifen-und-bedingungen.md)):

```hcl
output "config_pfade" {
  value = { for umgebung, instanz in module.webapp : umgebung => instanz.config_path }
}
```

Auch im State ist das sichtbar: Statt `module.webapp.local_file.app_config` steht dort für jede Umgebung ein eigener Eintrag, z.B. `module.webapp["dev"].local_file.app_config`.

## Die Docker-Variante

Im Beispiel unten simuliert das Modul eine "App-Konfiguration" nur über `local_file`, damit es ganz ohne weitere Abhängigkeiten läuft. Das Prinzip bleibt aber exakt dasselbe, wenn das Modul echte, laufende Container über den `docker`-Provider erstellt (lokal installiertes Docker vorausgesetzt, kein Cloud-Zugang nötig):

```hcl
# modules/webapp/main.tf
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "app" {
  name  = "app-${var.name}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.port
  }
}
```

Mit demselben `for_each`-`module`-Block wie oben entstehen daraus drei komplett unabhängige, gleichzeitig laufende Container - dev, staging und prod - aus einem einzigen Aufruf, jeder auf einem eigenen `var.port`. Genau dasselbe Prinzip funktioniert 1:1 auch mit echten Cloud-Ressourcen wie einer `azurerm_linux_web_app` oder einer `aws_instance`.

## Selbst ausprobieren

In diesem Ordner liegt das lauffähige Beispiel mit dem `local`-Provider:

```bash
terraform init
terraform apply
terraform state list
terraform output
```

`terraform state list` zeigt für jede Umgebung eine eigene Modul-Instanz (`module.webapp["dev"]`, `module.webapp["staging"]`, `module.webapp["prod"]`), und im Ordner `output/` liegt für jede Umgebung die passende Konfigurationsdatei - erzeugt aus einem einzigen `module`-Block.
