package provider

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/yourorg/terraform-provider-custom/client"
)

func resourceResource() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceResourceCreate,
		ReadContext:   resourceResourceRead,
		UpdateContext: resourceResourceUpdate,
		DeleteContext: resourceResourceDelete,
		Schema: map[string]*schema.Schema{
			"name": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Name of the resource",
			},
			"description": {
				Type:        schema.TypeString,
				Optional:    true,
				Description: "Description of the resource",
			},
			"enabled": {
				Type:        schema.TypeBool,
				Optional:    true,
				Default:     true,
				Description: "Whether the resource is enabled",
			},
			"tags": {
				Type:        schema.TypeMap,
				Optional:    true,
				Description: "Tags for the resource",
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"created_at": {
				Type:        schema.TypeString,
				Computed:    true,
				Description: "Timestamp when the resource was created",
			},
			"updated_at": {
				Type:        schema.TypeString,
				Computed:    true,
				Description: "Timestamp when the resource was last updated",
			},
		},
		Importer: &schema.ResourceImporter{
			StateContext: schema.ImportStatePassthroughContext,
		},
	}
}

func resourceResourceCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.Client)
	var diags diag.Diagnostics

	name := d.Get("name").(string)
	description := d.Get("description").(string)
	enabled := d.Get("enabled").(bool)
	tags := d.Get("tags").(map[string]interface{})

	resource := &client.Resource{
		Name:        name,
		Description: description,
		Enabled:     enabled,
		Tags:        convertTags(tags),
	}

	createdResource, err := c.CreateResource(resource)
	if err != nil {
		return diag.FromErr(err)
	}

	d.SetId(createdResource.ID)
	return resourceResourceRead(ctx, d, m)
}

func resourceResourceRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.Client)
	var diags diag.Diagnostics

	resourceID := d.Id()

	resource, err := c.GetResource(resourceID)
	if err != nil {
		return diag.FromErr(err)
	}

	if resource == nil {
		d.SetId("")
		return diags
	}

	d.Set("name", resource.Name)
	d.Set("description", resource.Description)
	d.Set("enabled", resource.Enabled)
	d.Set("tags", resource.Tags)
	d.Set("created_at", resource.CreatedAt)
	d.Set("updated_at", resource.UpdatedAt)

	return diags
}

func resourceResourceUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.Client)

	resourceID := d.Id()

	if d.HasChanges("name", "description", "enabled", "tags") {
		resource := &client.Resource{
			ID:          resourceID,
			Name:        d.Get("name").(string),
			Description: d.Get("description").(string),
			Enabled:     d.Get("enabled").(bool),
			Tags:        convertTags(d.Get("tags").(map[string]interface{})),
		}

		_, err := c.UpdateResource(resource)
		if err != nil {
			return diag.FromErr(err)
		}
	}

	return resourceResourceRead(ctx, d, m)
}

func resourceResourceDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.Client)
	var diags diag.Diagnostics

	resourceID := d.Id()

	err := c.DeleteResource(resourceID)
	if err != nil {
		return diag.FromErr(err)
	}

	d.SetId("")
	return diags
}

func convertTags(tags map[string]interface{}) map[string]string {
	result := make(map[string]string)
	for k, v := range tags {
		result[k] = v.(string)
	}
	return result
}
