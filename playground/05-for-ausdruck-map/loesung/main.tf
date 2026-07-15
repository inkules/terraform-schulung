locals {
  preise_brutto = { for produkt, preis in var.preise_netto : produkt => format("%.2f", preis * 1.19) }
}

output "preise_brutto" {
  value = local.preise_brutto
}
