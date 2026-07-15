resource "local_file" "config" {
  filename = "${path.module}/output/${terraform.workspace}.txt"
  content  = "Workspace: ${terraform.workspace}\nSKU: ${local.einstellungen.sku}\nInstanzen: ${local.einstellungen.instance_count}"
}
