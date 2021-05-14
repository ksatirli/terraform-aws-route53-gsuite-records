data "aws_route53_zone" "zone" {
  zone_id = var.zone_id
}

variable "zone_id" {
  type        = string
  description = "ID of the DNS Zone to store Records in"
}

variable "record_ttl" {
  type        = string
  description = "TTL for all DNS records"
  default     = 3600
}

variable "mx_records" {
  type        = list(string)
  description = "List of MX Records"
  default = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 alt3.aspmx.l.google.com",
    "10 alt4.aspmx.l.google.com"
  ]
}

variable "mx_verification_record_priority" {
  type        = string
  description = "MX Verification Record Priority"
  default     = 15
}

variable "mx_verification_record_prefix" {
  type        = string
  description = "MX Verification Record Prefix (without `.mx-verification.google.com`)"
  default     = null
}

variable "mx_verification_record_suffix" {
  type        = string
  description = "MX Verification Record Suffix"
  default     = ".mx-verification.google.com"
}

variable "dnssec_mx_records" {
  type        = list(string)
  description = "List of MX Records"
  default = [
    "1 mx1.smtp.goog",
    "5 mx2.smtp.goog",
    "5 mx3.smtp.goog",
    "10 mx4.smtp.goog"
  ]
}

variable "dkim_record_key" {
  type        = string
  description = "DKIM Identifier Record (without `._domainkey`)"
  default     = "google"
}

variable "dkim_record_value" {
  type        = string
  description = "DKIM Identifier Value"
  default     = null
}

variable "dmarc_protocol_version" {
  type        = string
  description = "Version of DMARC Protocol"
  default     = "DMARC1"
}

variable "dmarc_policy_type" {
  type        = string
  description = "Type of DMARC Policy"
  default     = "none"
}

variable "dmarc_policy_percentage" {
  type        = string
  description = "Percentage of suspicious messages the Policy should apply to"
  default     = 100
}

variable "dmarc_report_recipient" {
  type        = string
  description = "Recipient of DMARC Reports"
  default     = null
}

variable "dmarc_subdomain_policy_type" {
  type        = string
  description = "Type of DMARC Policy for Subdomains"
  default     = "none"
}

variable "dmarc_dkim_alignment_mode" {
  type        = string
  description = "Alignment mode for DKIM Signatures"
  default     = "r"
}

variable "dmarc_spf_alignment_mode" {
  type        = string
  description = "Alignment mode for SPF Records"
  default     = "r"
}

variable "use_dnssec_signed_records" {
  type        = bool
  description = "Toggle to enable DNSSEC-signed Records for Gmail"
  default     = false
}

variable "gsuite_custom_url_cname" {
  type        = string
  description = "CNAME Record for custom Application URLs"
  default     = "ghs.googlehosted.com"
}

variable "custom_gmail_subdomain" {
  type        = string
  description = "Subdomain for custom Gmail URL"
  default     = null
}

variable "custom_calendar_subdomain" {
  type        = string
  description = "Subdomain for custom Calendar URL"
  default     = null
}

variable "custom_docs_subdomain" {
  type        = string
  description = "Subdomain for custom Docs URL"
  default     = null
}

variable "custom_drive_subdomain" {
  type        = string
  description = "Subdomain for custom Drive URL"
  default     = null
}

variable "custom_sites_subdomain" {
  type        = string
  description = "Subdomain for custom Sites URL"
  default     = null
}

variable "custom_groups_subdomain" {
  type        = string
  description = "Subdomain for custom Groups for Business URL"
  default     = null
}

variable "apex_spf_txt" {
  type        = string
  description = "SPF Record for Gmail"
  default     = "v=spf1 include:_spf.google.com ~all"
}

variable "apex_verification_txt" {
  type        = string
  description = "Google Domain Verification Record"
  default     = null
}

variable "redirect_naked_domain" {
  type        = bool
  description = "Toggle to redirect naked domain"
  default     = false
}

variable "apex_domain_redirect_records" {
  type        = list
  description = ""
  default = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21"
  ]
}

locals {
  zone_name              = data.aws_route53_zone.zone.name
  non_verification_records = var.use_dnssec_signed_records ? var.dnssec_mx_records : var.mx_records
  verification_record    = var.mx_verification_record_prefix != null ? format("%g %s%s", var.mx_verification_record_priority, var.mx_verification_record_prefix, var.mx_verification_record_suffix) : null
  gmail_records          = local.verification_record != null ? concat(non_verification_records, [local.verification_record]) : non_verification_records
  dmarc_report_recipient = var.dmarc_report_recipient != null ? var.dmarc_report_recipient : format("hostmaster@%s", local.zone_name)
  dmarc_policy           = "v=${var.dmarc_protocol_version}; p=${var.dmarc_policy_type}; pct=${var.dmarc_policy_percentage}; rua=mailto:${local.dmarc_report_recipient}; sp=${var.dmarc_subdomain_policy_type} adkim=${var.dmarc_dkim_alignment_mode}; aspf=${var.dmarc_spf_alignment_mode}"
  apex_txt_record        = var.apex_verification_txt != null ? [var.apex_spf_txt, var.apex_verification_txt] : [var.apex_spf_txt]
}
