variable "preise_netto" {
  description = "Nettopreise pro Produkt"
  type        = map(number)
  default = {
    kaffee = 3.50
    tee    = 2.80
    kuchen = 4.20
  }
}
