resource "local_file" "pro_umgebung" {
  for_each = var.umgebungen

  filename = "${path.module}/output/${each.value}.txt"
  content  = "Umgebung: ${each.value}\nPizza: ${lookup(var.pizza_je_umgebung, each.value, "Margherita")}"
}
