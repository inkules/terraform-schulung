locals {
  greeting = upper("Hallo, ${var.name}!")
  facts    = join("\n", var.fun_facts)
}
