# Terraform Module: G Suite Records

> Terraform Module for managing AWS Route 53 DNS Records for [G Suite](https://support.google.com/a/answer/48090).

## Table of Contents

- [Terraform Module: G Suite Records](#terraform-module-g-suite-records)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
  - [Notes](#notes)
    - [Debugging](#debugging)
      - [Check MX](#check-mx)
      - [Flushing DNS Cache](#flushing-dns-cache)
    - [Recommended: Generate DKIM Records](#recommended-generate-dkim-records)
    - [Optional: Customizing a G Suite service URL](#optional-customizing-a-g-suite-service-url)
    - [Optional: Redirecting naked domain](#optional-redirecting-naked-domain)
  - [Author Information](#author-information)
  - [License](#license)

## Requirements

This module requires Terraform version `0.12.0` or newer.

## Dependencies

This module depends on a correctly configured [AWS Provider](https://www.terraform.io/docs/providers/aws/index.html) in your Terraform codebase.

## Usage

Add the module to your Terraform resources like so:

```hcl
module "gsuite_records" {
  source              = "operatehappy/route53-gsuite-records/aws"
  version             = "0.9.0"
  zone_id             = "Z3P5QSUBK4POTI"
  // TODO
}
```

Then, fetch the module from the [Terraform Registry](https://registry.terraform.io/modules/operatehappy/route53-gsuite-records) using `terraform get`.

### Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| apex_verification_txt | Google Domain Verification Record | `string` | n/a |
| custom_calendar_subdomain | Subdomain for custom Calendar URL | `string` | n/a |
| custom_docs_subdomain | Subdomain for custom Docs URL | `string` | n/a |
| custom_drive_subdomain | Subdomain for custom Drive URL | `string` | n/a |
| custom_gmail_subdomain | Subdomain for custom Gmail URL | `string` | n/a |
| custom_groups_subdomain | Subdomain for custom Groups for Business URL | `string` | n/a |
| custom_sites_subdomain | Subdomain for custom Sites URL | `string` | n/a |
| dkim_record_value | DKIM Identifier Value | `string` | n/a |
| dmarc_report_recipient | Recipient of DMARC Reports | `string` | n/a |
| mx_verification_record_prefix | MX Verification Record Prefix (without `.mx-verification.google.com`) | `string` | n/a |
| zone_id | ID of the DNS Zone to store Records in | `string` | n/a |
| apex_domain_redirect_records | n/a | `list` | <pre>[<br>  "216.239.32.21",<br>  "216.239.34.21",<br>  "216.239.36.21",<br>  "216.239.38.21"<br>]</pre> |
| apex_spf_txt | SPF Record for Gmail | `string` | `"v=spf1 include:_spf.google.com ~all"` |
| dkim_record_key | DKIM Identifier Record (without `._domainkey`) | `string` | `"google"` |
| dmarc_dkim_alignment_mode | Alignment mode for DKIM Signatures | `string` | `"r"` |
| dmarc_policy_percentage | Percentage of suspicious messages the Policy should apply to | `string` | `100` |
| dmarc_policy_type | Type of DMARC Policy | `string` | `"none"` |
| dmarc_protocol_version | Version of DMARC Protocol | `string` | `"DMARC1"` |
| dmarc_spf_alignment_mode | Alignment mode for SPF Records | `string` | `"r"` |
| dmarc_subdomain_policy_type | Type of DMARC Policy for Subdomains | `string` | `"none"` |
| dnssec_mx_records | List of MX Records | `list(string)` | <pre>[<br>  "1 mx1.smtp.goog",<br>  "5 mx2.smtp.goog",<br>  "5 mx3.smtp.goog",<br>  "10 mx4.smtp.goog"<br>]</pre> |
| gsuite_custom_url_cname | CNAME Record for custom Application URLs | `string` | `"ghs.googlehosted.com"` |
| mx_records | List of MX Records | `list(string)` | <pre>[<br>  "1 aspmx.l.google.com",<br>  "5 alt1.aspmx.l.google.com",<br>  "5 alt2.aspmx.l.google.com",<br>  "10 alt3.aspmx.l.google.com",<br>  "10 alt4.aspmx.l.google.com"<br>]</pre> |
| mx_verification_record_priority | MX Verification Record Priority | `string` | `15` |
| mx_verification_record_suffix | MX Verification Record Suffix | `string` | `".mx-verification.google.com"` |
| record_ttl | TTL for all DNS records | `string` | `3600` |
| redirect_naked_domain | Toggle to redirect naked domain | `bool` | `false` |
| use_dnssec_signed_records | Toggle to enable DNSSEC-signed Records for Gmail | `bool` | `false` |

### Outputs

| Name | Description |
|------|-------------|
| apex_txt_record | interpolated value of `local.apex_txt_record` |
| dmarc_policy | interpolated value of `local.dmarc_policy` |
| gsuite-toolbox-check-mx-url | Direct Link to G Suite Toolbox Check MX tool |

### Notes

On top of adding the required `MX` records, this module supports a variety of optional settings that can be useful for better integrating with _G Suite_.

This section contains step-by-step guides with additional information and helpful links to the [G Suite Admin Help Center](https://support.google.com/a/#topic=7570177).

#### Debugging

Google provides a number of tools for _G Suite_ administrators that are geared towards debugging.

##### Check MX

You can verify your domain's records (`MX`, `SPF`, `DKIM`, and `DMARC`) are correctly set up by using the [Check MX](https://toolbox.googleapps.com/apps/checkmx/) tool.

To make using this tool easier, this Terraform module generates a direct link as part of the module outputs. This link pre-fills your _G Suite_ domain and DKIM key.

The output is part of the module and can be retrieved via `terraform console`, but it can also be bubbled up to display as an output in _your_ Terraform configuration using the following example:

```hcl
output "gsuite-toolbox-check-mx-url" {
  value = module.gsuite-records.gsuite-toolbox-check-mx-url
  description = "Direct Link to G Suite Toolbox Check MX tool"
}
```

Note that in the above example, the output requires this module to be referenced as `gsuite-records`. Should you use a different name, you will need to adjust the `value` reference to reflect this.

Once you have completed a `terraform apply` run, the direct link to the [Check MX](https://toolbox.googleapps.com/apps/checkmx/) tool can be found using `terraform output gsuite-toolbox-check-mx-url`.

##### Flushing DNS Cache

You can flush Google's DNS cache for a domains specific record types by using the [Flush Cache](https://developers.google.com/speed/public-dns/cache) tool.

Note the instructions on that page for further explanations.

#### Automatic: Prevent spoofing with SPF records

Described in _Help Center_ article [Help prevent email spoofing with SPF records
](https://support.google.com/a/answer/33786), this module sets a default SPF record of `v=spf1 include:_spf.google.com ~all`, automatically.

This value can be changed by setting the contents of the `apex_spf_txt` variable to a policy of your chosing.

#### Recommended: Generate DKIM Records

Using DomainKeys Identified Mail (DKIM) helps prevent spoofing on outgoing messages sent from your domain.

Described in _Help Center_ article [Set up DKIM to prevent email spoofing](https://support.google.com/a/answer/174124), the required steps to enable this feature are:

1. Open the [Google Admin](https://admin.google.com/AdminHome) interface
2. Click on the [Apps](https://admin.google.com/ac/apps) icon
3. Click on the [G Suite](https://admin.google.com/ac/appslist/core) icon
4. Click on the [Gmail](https://admin.google.com/AdminHome#AppDetails:service=email) menu item
5. Click on the [Authenticate email](https://admin.google.com/ac/apps/gmail/authenticateemail) menu item
6. Verify that the value in the _Selected domain_ drop down menu is correct
7. Click on the _GENERATE NEW RECORD_ button
8. Select a _DKIM key bit length_ of `1024` bits
9. Select a _Prefix selector_ (or keep the default of `google`)
10. Click on the _GENERATE_ button

Once these steps have been completed, the _DKIM Authentication_ interface will generate a DNS record for you.

Copy the _TXT record value_ (starting with `v=DKIM1; k=rsa;`) and add it to the module's configuration using the `dkim_record_value` variable.

If you chose to change the _Prefix selector (step 9), add it to the module's configuration using the `dkim_record_key` variable.

```hcl
module "gsuite-records" {
  
  // module configuration as listed above

  dkim_record_value = "v=DKIM1; k=rsa; p=MIG...QAB"
  dkim_record_key = "google"

}
```

After applying these changes (using `terraform apply`), return to the [Authenticate email](https://admin.google.com/ac/apps/gmail/authenticateemail) interface and click the _START AUTHENTICATION_ button.

Note that if you are activating Gmail (the service) for your G Suite account for the _first_ time, the interface may impose a 24 to 72 hour wait before DKIM records can be generated.

Once the records have been generated and applied, it may take up to 72 hours more for DNS changes to fully propagate. See the [Flushing DNS Cache](#flushing-dns-cache) Notes for additional help.

#### Recommended: Turn on DMARC

Using Domain-based Message Authentication, Reporting, and Conformance (DMARC) helps manage suspicious emails.

Described in _Help Center_ article [Turn on DMARC](https://support.google.com/a/answer/2466563), the required steps to enable this feature are:

1. Craft a DMARC policy, consisting of the following items:
   * Version of DMARC Protocol, configured through the `dmarc_protocol_version` variable
   * Type of DMARC Policy, configured through the `dmarc_policy_type` variable
   * Percentage of suspicious messages the Policy should apply to, configured through the `dmarc_policy_percentage` variable
   * Recipient of DMARC Reports, configured through the `dmarc_report_recipient` variable
   * Type of DMARC Policy for Subdomains, configured through the `dmarc_subdomain_policy_type` variable
   * Alignment mode for DKIM Signatures, configured through the `dmarc_dkim_alignment_mode` variable
   * Alignment mode for SPF Records, configured through the `dmarc_spf_alignment_mode` variable

Except for the `dmarc_report_recipient` variable, all of these settings have sane defaults. Their default values can be found in the [Inputs](#inputs) section.

Note that setting a value for the `dmarc_report_recipient` variable will result in the following policy to be applied:

```shell
"v=DMARC1; p=none; pct=100; rua=mailto:${var.dmarc_report_recipient}; sp=none adkim=r; aspf=r"
```

Crafting a _"correct"_ DMARC Policy is highly specific to your organization's use case and outside the scope of this document. The _Help Center_ article on [DMARC values](https://support.google.com/a/answer/2466563#dmarc-values) provides a good starting point.

The module-generated DMARC Policy is also available as an output under the `dmarc_policy` identifier.

#### Optional: Customizing a G Suite service URL

Described in _Help Center_ article [Customize a G Suite service URL](https://support.google.com/a/answer/53340), the required steps for creating one (or all) redirects are:

1. Open the [Google Admin](https://admin.google.com/AdminHome) interface
2. Click on the [Company profile](https://admin.google.com/AdminHome#CompanyProfile:] icon
3. Click on the _Show more_ menu item to display additional options
4. Click on the [Custom URLs](https://admin.google.com/AdminHome#CompanyProfile:flyout=customUrl) menu item
5. Enter custom URLs for any (or all) of the following services
  * Gmail
  * Calendar
  * Drive
  * Sites
  * Groups for Business

Then, using those same values, set the following variables in this module's configuration:

```hcl
  custom_gmail_subdomain    = "mail"
  custom_calendar_subdomain = "calendar"
  custom_drive_subdomain    = "drive"
  custom_sites_subdomain    = "sites"
  custom_groups_subdomain   = "groups"
```

Note that these are example values; your actual values might differ.

As indicated in the interface, these services _need_ to be subdomains of a(ny) domain as added in the [Manage Domains](https://admin.google.com/AdminHome#Domains:) interface.

#### Optional: Redirecting naked domain

Described in _Help Center_ article [Set up the "naked" domain address for your site](https://support.google.com/a/answer/2518373), the required steps for redirecting your domain apex (e.g.: `example.com`) are:

1. Enter a value in the [Google Admin](https://admin.google.com/AdminHome?fral=1&chromeless=1#OGX:DomainSettingsChangeNakedRedirect) interface for naked domain redirects. This could be a redirect from `example.com` to `www.example.com`
2. Create an _A Record_ for the domain by setting by setting the `redirect_naked_domain` variable to true
3. Should the set of Google-provided [IP addresses](https://admin.google.com/AdminHome?chromeless=1#OGX:SetupARecordInstructions) differ from the set specified in the `apex_domain_redirect_records` variable (see `variables.tf`), you can override them by passing your own list to the module:

## Author Information

This module is maintained by the contributors listed on [GitHub](https://github.com/operatehappy/terraform-aws-route53-workmail-records/graphs/contributors)

Development of this module was sponsored by [Operate Happy](https://github.com/operatehappy).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
