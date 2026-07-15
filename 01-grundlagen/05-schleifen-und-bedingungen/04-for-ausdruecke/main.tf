locals {
  umgebungen_gross = [for u in var.umgebungen : upper(u)]

  pizza_gross = {
    for umgebung, pizza in var.pizza_je_umgebung :
    umgebung => upper(pizza)
  }
}
