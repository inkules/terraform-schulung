# Ein Eintrag pro Workspace/Umgebung. Ein neuer Workspace braucht nur eine
# neue Zeile hier, keine neue Kopie der restlichen Konfiguration.
locals {
  einstellungen_je_workspace = {
    default = { sku = "B1", instance_count = 1 }
    dev     = { sku = "B1", instance_count = 1 }
    staging = { sku = "B2", instance_count = 2 }
    prod    = { sku = "P1v2", instance_count = 3 }
  }

  einstellungen = lookup(
    local.einstellungen_je_workspace,
    terraform.workspace,
    local.einstellungen_je_workspace["default"]
  )
}
