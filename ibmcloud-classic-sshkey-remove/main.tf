resource "null_resource" "remove_key" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/removekey.sh"
    environment = {
      HOME       = "${abspath(path.module)}/home"
      IC_API_KEY = var.ibmcloud_api_key
      SSHKEY_ID  = var.SSHKEY_ID
    }
  }
}
