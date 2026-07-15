resource "local_file" "greeting" {
  filename = "${path.module}/greeting.txt"
  content  = "${local.greeting}\n\n${local.facts}\n"
}
