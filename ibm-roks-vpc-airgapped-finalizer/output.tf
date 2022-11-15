output "argo_username" {
  value = "admin"
}

output "argo_password" {
  value = data.external.sshoutputs.result.argo_password
}

output "argo_url" {
  value = data.external.sshoutputs.result.argo_url
}

output "vpn_configuration" {
  value = base64encode(data.template_file.vpn_configuration.rendered)
}
