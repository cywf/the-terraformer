package provider

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/yourorg/terraform-provider-custom/client"
)

// Provider returns a terraform.ResourceProvider.
func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"api_url": {
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("CUSTOM_API_URL", nil),
				Description: "The URL of the API endpoint",
			},
			"api_key": {
				Type:        schema.TypeString,
				Required:    true,
				Sensitive:   true,
				DefaultFunc: schema.EnvDefaultFunc("CUSTOM_API_KEY", nil),
				Description: "API key for authentication",
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"custom_resource": resourceResource(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"custom_resource": dataSourceResource(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	apiURL := d.Get("api_url").(string)
	apiKey := d.Get("api_key").(string)

	var diags diag.Diagnostics

	if apiURL == "" {
		diags = append(diags, diag.Diagnostic{
			Severity: diag.Error,
			Summary:  "Unable to create client",
			Detail:   "API URL is required",
		})
		return nil, diags
	}

	c, err := client.NewClient(apiURL, apiKey)
	if err != nil {
		diags = append(diags, diag.Diagnostic{
			Severity: diag.Error,
			Summary:  "Unable to create client",
			Detail:   err.Error(),
		})
		return nil, diags
	}

	return c, diags
}
