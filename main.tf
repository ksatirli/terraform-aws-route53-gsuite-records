resource "aws_route53_record" "gmail" {
  zone_id = var.zone_id
  name    = local.zone_name
  type    = "MX"
  ttl     = var.record_ttl
  records = local.gmail_records
}

resource "aws_route53_record" "dkim" {
  count   = var.dkim_record_value != null ? 1 : 0
  zone_id = var.zone_id
  name    = "${var.dkim_record_key}._domainkey.${local.zone_name}"
  type    = "TXT"
  ttl     = var.record_ttl
  records = [var.dkim_record_value]
}

resource "aws_route53_record" "custom-gmail-subdomain" {
  count   = var.custom_gmail_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_gmail_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}

resource "aws_route53_record" "custom-calendar-subdomain" {
  count   = var.custom_calendar_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_calendar_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}

resource "aws_route53_record" "custom-docs-subdomain" {
  count   = var.custom_docs_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_docs_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}


resource "aws_route53_record" "custom-drive-subdomain" {
  count   = var.custom_drive_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_drive_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}

resource "aws_route53_record" "custom-sites-subdomain" {
  count   = var.custom_sites_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_sites_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}

resource "aws_route53_record" "custom-groups-subdomain" {
  count   = var.custom_groups_subdomain != null ? 1 : 0
  zone_id = var.zone_id
  name    = format("%s.%s", var.custom_groups_subdomain, local.zone_name)
  type    = "CNAME"
  ttl     = var.record_ttl
  records = [var.gsuite_custom_url_cname]
}

resource "aws_route53_record" "dmarc-policy" {
  count   = var.dmarc_report_recipient != null ? 1 : 0
  zone_id = var.zone_id
  name    = "_dmarc.${local.zone_name}"
  type    = "TXT"
  ttl     = var.record_ttl
  records = [local.dmarc_policy]
}

resource "aws_route53_record" "apex-txt-record" {
  zone_id = var.zone_id
  name    = local.zone_name
  type    = "TXT"
  ttl     = var.record_ttl
  records = local.apex_txt_record
}

resource "aws_route53_record" "naked-domain-redirect" {
  count   = var.redirect_naked_domain ? 1 : 0
  zone_id = var.zone_id
  name    = local.zone_name
  type    = "A"
  ttl     = var.record_ttl
  records = var.apex_domain_redirect_records
}
