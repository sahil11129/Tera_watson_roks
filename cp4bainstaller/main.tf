resource "local_file" "home" {
  content  = "home folder"
  filename = "${path.module}/home/home.txt"
}

# CP Installer
resource "null_resource" "cp4ba_install" {
  provisioner "local-exec" {
    command = "./dtecpinstaller.sh"
    environment = {
      HOME             = "${abspath(path.module)}/home"
      OWNER            = var.user_email
      ENTITLEKEY       = var.entitlmentkey
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
      CLUSTERNAME      = var.cluster_name
      CASEVERSION      = var.CASEVERSION
      CP4BAVERSION     = var.CP4BAVERSION
    }
    working_dir = "${abspath(path.module)}/scripts"
  }
}
