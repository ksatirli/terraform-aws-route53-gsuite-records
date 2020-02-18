output "dmarc_policy" {
  value       = local.dmarc_policy
  description = "interpolated value of `local.dmarc_policy`"
}

output "apex_txt_record" {
  value       = local.apex_txt_record
  description = "interpolated value of `local.apex_txt_record`"
}

output "gsuite-toolbox-check-mx-url" {
  value       = "https://toolbox.googleapps.com/apps/checkmx/check?domain=${trimsuffix(local.zone_name, ".")}&dkim_selector=${var.dkim_record_key}"
  description = "Direct Link to G Suite Toolbox Check MX tool"
}
