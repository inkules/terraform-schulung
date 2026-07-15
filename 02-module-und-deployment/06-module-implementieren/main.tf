locals {
  umgebungen = {
    dev = {
      sku            = "B1"
      instance_count = 1
    }
    staging = {
      sku            = "B2"
      instance_count = 2
    }
    prod = {
      sku            = "P1v2"
      instance_count = 3
    }
  }
}

# for_each auf dem module-Block: eine komplette Modul-Instanz pro Umgebung.
# Eine vierte Umgebung hinzufügen = eine weitere Zeile in local.umgebungen,
# kein zusätzlicher module-Block, kein kopierter Ordner.
module "webapp" {
  for_each = local.umgebungen

  source         = "./modules/webapp"
  name           = each.key
  sku            = each.value.sku
  instance_count = each.value.instance_count
  output_dir     = "${path.module}/output"
}
