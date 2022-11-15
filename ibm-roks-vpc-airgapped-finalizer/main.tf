resource "local_file" "argo_script" {
  content = templatefile("${path.module}/scripts/get-argo-info.sh.tmpl", {
    ssh_key      = var.ssh_key
    username     = var.username
    bastion_host = var.bastion_host
  })
  filename = "${path.module}/scripts/get-argo-info.sh"
}

data "external" "sshoutputs" {
  depends_on = [
    resource.local_file.argo_script,
  ]
  program = ["bash", "${path.module}/scripts/get-argo-info.sh"]
}


resource "null_resource" "finalizer" {
  depends_on = [
    data.external.sshoutputs,
  ]
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.bastion_host
    private_key = chomp(file(var.ssh_key))
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "for inventory in /home/${var.username}/inventory_*; do",
      "  sed -i \"s/ibmcloud_api_key=.*/ibmcloud_api_key=REDACTED/g\" $inventory",
      "  sed -i \"s/openshift_pull_secret=.*/openshift_pull_secret=REDACTED/g\" $inventory",
      "  sed -i \"s/entitlement_key=.*/entitlement_key=REDACTED/g\" $inventory",
      "done",
      "oc create user IAM#${var.user_email} || true",
      "oc create identity IAM:IBMid-${var.user_id} || true",
      "oc create useridentitymapping IAM:IBMid-${var.user_id} IAM#${var.user_email} || true",
      "oc adm policy add-cluster-role-to-user cluster-admin IAM#${var.user_email} || true",
      "ibmcloud logout",
    ]
  }
}

# resource "null_resource" "add_user_rbac" {
#   provisioner "local-exec" {
#     command = "${path.module}/scripts/add-user-rbac.sh || true"
#     environment = {
#       HOME    = "${abspath(path.module)}/home"
#       EMAIL   = var.user_email
#       USER_ID = var.user_id
#     }
#   }
#   depends_on = [
#     null_resource.invite_user,
#     null_resource.kubeconfig
#   ]
# }
# oc create user IAM#${EMAIL}
# oc create identity IAM:IBMid-${USER_ID}
# oc create useridentitymapping IAM:IBMid-${USER_ID} IAM#${EMAIL}
# oc adm policy add-cluster-role-to-user cluster-admin IAM#${EMAIL}

resource "null_resource" "generate_certificates" {
  provisioner "local-exec" {
    command = <<EOF
cd ${path.module}/easy-rsa/${var.vpc_name}/easyrsa3
find . -name '${var.user_id}-${var.region}.vpn.ibm.com.*' -exec rm {} \;
EASYRSA_CERT_EXPIRE=90 ./easyrsa build-client-full ${var.user_id}-${var.region}.vpn.ibm.com nopass
EOF
  }
}

data "external" "vpn_hostname" {
  depends_on = [
    null_resource.generate_certificates,
  ]
  program = ["bash", "${path.module}/scripts/get-vpn-hostname.sh"]
  query = {
    ibmcloud_api_key = var.ibmcloud_api_key
    region           = var.region
    vpn_name         = "${var.vpc_name}-vpn"
  }
}

data "external" "vpn_server_certs" {
  depends_on = [
    null_resource.generate_certificates
  ]
  program = ["bash", "${path.module}/scripts/vpn-server-certs.sh"]
  query = {
    pki_path = "${path.module}/easy-rsa/${var.vpc_name}/easyrsa3/pki"
    region   = var.region
    userid   = var.user_id
  }
}


data "template_file" "vpn_configuration" {
  template = file("${path.module}/templates/vpn.ovpn.tmpl")
  vars = {
    ca_cert      = chomp(base64decode(data.external.vpn_server_certs.result.ca_cert))
    client_cert  = chomp(base64decode(data.external.vpn_server_certs.result.client_cert))
    client_key   = chomp(base64decode(data.external.vpn_server_certs.result.client_key))
    vpn_hostname = data.external.vpn_hostname.result.vpn_hostname
  }
}
