package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client manages communication with the API
type Client struct {
	BaseURL    string
	APIKey     string
	HTTPClient *http.Client
}

// Resource represents a custom resource
type Resource struct {
	ID          string            `json:"id,omitempty"`
	Name        string            `json:"name"`
	Description string            `json:"description,omitempty"`
	Enabled     bool              `json:"enabled"`
	Tags        map[string]string `json:"tags,omitempty"`
	CreatedAt   string            `json:"created_at,omitempty"`
	UpdatedAt   string            `json:"updated_at,omitempty"`
}

// NewClient creates a new API client
func NewClient(baseURL, apiKey string) (*Client, error) {
	if baseURL == "" {
		return nil, fmt.Errorf("base URL cannot be empty")
	}
	if apiKey == "" {
		return nil, fmt.Errorf("API key cannot be empty")
	}

	return &Client{
		BaseURL: baseURL,
		APIKey:  apiKey,
		HTTPClient: &http.Client{
			Timeout: time.Second * 30,
		},
	}, nil
}

// CreateResource creates a new resource
func (c *Client) CreateResource(resource *Resource) (*Resource, error) {
	body, err := json.Marshal(resource)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/resources", c.BaseURL), bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("failed to create resource: %s", string(bodyBytes))
	}

	var createdResource Resource
	if err := json.NewDecoder(resp.Body).Decode(&createdResource); err != nil {
		return nil, err
	}

	return &createdResource, nil
}

// GetResource retrieves a resource by ID
func (c *Client) GetResource(id string) (*Resource, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("%s/resources/%s", c.BaseURL, id), nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return nil, nil
	}

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("failed to get resource: %s", string(bodyBytes))
	}

	var resource Resource
	if err := json.NewDecoder(resp.Body).Decode(&resource); err != nil {
		return nil, err
	}

	return &resource, nil
}

// UpdateResource updates an existing resource
func (c *Client) UpdateResource(resource *Resource) (*Resource, error) {
	body, err := json.Marshal(resource)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("PUT", fmt.Sprintf("%s/resources/%s", c.BaseURL, resource.ID), bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("failed to update resource: %s", string(bodyBytes))
	}

	var updatedResource Resource
	if err := json.NewDecoder(resp.Body).Decode(&updatedResource); err != nil {
		return nil, err
	}

	return &updatedResource, nil
}

// DeleteResource deletes a resource by ID
func (c *Client) DeleteResource(id string) error {
	req, err := http.NewRequest("DELETE", fmt.Sprintf("%s/resources/%s", c.BaseURL, id), nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to delete resource: %s", string(bodyBytes))
	}

	return nil
}
