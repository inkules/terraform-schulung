data "local_file" "version" {
  filename = "${path.module}/VERSION"
}

resource "local_file" "deploy_info" {
  filename = "${path.module}/output/deploy-info.txt"
  content  = "Deploye Version: ${trimspace(data.local_file.version.content)}"
}
