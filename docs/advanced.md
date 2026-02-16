# Advanced Features

Explore advanced framework capabilities including actions and ephemeral resources.

## Actions

Actions are provider-defined operations that can be triggered independently of resource lifecycle. They provide a way to execute operations without managing state.

**Note:** Actions are a newer feature in terraform-plugin-framework. Check version compatibility.

### Action Interface

```go
type Action interface {
    // Metadata returns action name
    Metadata(context.Context, ActionMetadataRequest, *ActionMetadataResponse)

    // Schema defines action parameters
    Schema(context.Context, ActionSchemaRequest, *ActionSchemaResponse)

    // Run executes the action
    Run(context.Context, ActionRunRequest, *ActionRunResponse)
}
```

### Basic Action Implementation

```go
package action

import (
    "context"

    "github.com/hashicorp/terraform-plugin-framework/action"
    "github.com/hashicorp/terraform-plugin-framework/action/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

var _ action.Action = (*RestartServiceAction)(nil)

type RestartServiceAction struct {
    client *APIClient
}

func NewRestartServiceAction() action.Action {
    return &RestartServiceAction{}
}

func (a *RestartServiceAction) Metadata(ctx context.Context, req action.MetadataRequest, resp *action.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_restart_service"
}

func (a *RestartServiceAction) Schema(ctx context.Context, req action.SchemaRequest, resp *action.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Restart a service",
        Attributes: map[string]schema.Attribute{
            "service_id": schema.StringAttribute{
                Description: "ID of service to restart",
                Required:    true,
            },
            "force": schema.BoolAttribute{
                Description: "Force restart even if service is healthy",
                Optional:    true,
            },
            "status": schema.StringAttribute{
                Description: "Status after restart",
                Computed:    true,
            },
        },
    }
}

func (a *RestartServiceAction) Run(ctx context.Context, req action.RunRequest, resp *action.RunResponse) {
    var config struct {
        ServiceID types.String `tfsdk:"service_id"`
        Force     types.Bool   `tfsdk:"force"`
    }

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Execute action
    force := false
    if !config.Force.IsNull() {
        force = config.Force.ValueBool()
    }

    result, err := a.client.RestartService(ctx, config.ServiceID.ValueString(), force)
    if err != nil {
        resp.Diagnostics.AddError("Restart Failed", err.Error())
        return
    }

    // Set result
    var resultData struct {
        ServiceID types.String `tfsdk:"service_id"`
        Force     types.Bool   `tfsdk:"force"`
        Status    types.String `tfsdk:"status"`
    }

    resultData.ServiceID = config.ServiceID
    resultData.Force = config.Force
    resultData.Status = types.StringValue(result.Status)

    resp.Diagnostics.Append(resp.Result.Set(ctx, &resultData)...)
}
```

### Register Actions

```go
func (p *ExampleProvider) Actions(ctx context.Context) []func() action.Action {
    return []func() action.Action{
        NewRestartServiceAction,
        NewBackupDatabaseAction,
    }
}
```

### Action Usage

Actions are invoked via Terraform CLI (exact syntax depends on Terraform version):

```bash
terraform action example_restart_service \
  -var service_id="svc-123" \
  -var force=true
```

### When to Use Actions

Use actions for:
- **One-time operations** - Operations that don't need state tracking
- **Administrative tasks** - Backups, restarts, maintenance operations
- **Bulk operations** - Operations across multiple resources

Don't use actions for:
- **State management** - Use resources instead
- **Data queries** - Use data sources instead
- **Pure computation** - Use functions instead

## Ephemeral Resources

Ephemeral resources are session-scoped resources that exist only for the duration of a Terraform operation. They:
- Don't persist in state
- Are recreated on each Terraform run
- Useful for temporary credentials, session tokens, etc.

### Ephemeral Resource Interface

```go
type EphemeralResource interface {
    // Metadata returns resource type name
    Metadata(context.Context, EphemeralResourceMetadataRequest, *EphemeralResourceMetadataResponse)

    // Schema defines resource schema
    Schema(context.Context, EphemeralResourceSchemaRequest, *EphemeralResourceSchemaResponse)

    // Open creates the ephemeral resource
    Open(context.Context, EphemeralResourceOpenRequest, *EphemeralResourceOpenResponse)

    // Renew refreshes the ephemeral resource (optional)
    Renew(context.Context, EphemeralResourceRenewRequest, *EphemeralResourceRenewResponse)

    // Close destroys the ephemeral resource
    Close(context.Context, EphemeralResourceCloseRequest, *EphemeralResourceCloseResponse)
}
```

### Ephemeral Resource Implementation

```go
package ephemeral

import (
    "context"
    "time"

    "github.com/hashicorp/terraform-plugin-framework/ephemeral"
    "github.com/hashicorp/terraform-plugin-framework/ephemeral/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

var _ ephemeral.EphemeralResource = (*TemporaryCredentialResource)(nil)

type TemporaryCredentialResource struct {
    client *APIClient
}

func NewTemporaryCredentialResource() ephemeral.EphemeralResource {
    return &TemporaryCredentialResource{}
}

func (r *TemporaryCredentialResource) Metadata(ctx context.Context, req ephemeral.EphemeralResourceMetadataRequest, resp *ephemeral.EphemeralResourceMetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_temporary_credential"
}

func (r *TemporaryCredentialResource) Schema(ctx context.Context, req ephemeral.EphemeralResourceSchemaRequest, resp *ephemeral.EphemeralResourceSchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Temporary credential for accessing resources",
        Attributes: map[string]schema.Attribute{
            "role": schema.StringAttribute{
                Description: "Role to assume",
                Required:    true,
            },
            "duration": schema.Int64Attribute{
                Description: "Duration in seconds (default 3600)",
                Optional:    true,
            },
            "access_key": schema.StringAttribute{
                Description: "Temporary access key",
                Computed:    true,
                Sensitive:   true,
            },
            "secret_key": schema.StringAttribute{
                Description: "Temporary secret key",
                Computed:    true,
                Sensitive:   true,
            },
            "expires_at": schema.StringAttribute{
                Description: "Expiration time",
                Computed:    true,
            },
        },
    }
}
```

### Open Method

Create the ephemeral resource:

```go
func (r *TemporaryCredentialResource) Open(ctx context.Context, req ephemeral.EphemeralResourceOpenRequest, resp *ephemeral.EphemeralResourceOpenResponse) {
    var config struct {
        Role     types.String `tfsdk:"role"`
        Duration types.Int64  `tfsdk:"duration"`
    }

    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Default duration
    duration := 3600
    if !config.Duration.IsNull() {
        duration = int(config.Duration.ValueInt64())
    }

    // Create temporary credential
    cred, err := r.client.CreateTemporaryCredential(ctx, config.Role.ValueString(), duration)
    if err != nil {
        resp.Diagnostics.AddError("Failed to create credential", err.Error())
        return
    }

    // Set result
    var result struct {
        Role      types.String `tfsdk:"role"`
        Duration  types.Int64  `tfsdk:"duration"`
        AccessKey types.String `tfsdk:"access_key"`
        SecretKey types.String `tfsdk:"secret_key"`
        ExpiresAt types.String `tfsdk:"expires_at"`
    }

    result.Role = config.Role
    result.Duration = types.Int64Value(int64(duration))
    result.AccessKey = types.StringValue(cred.AccessKey)
    result.SecretKey = types.StringValue(cred.SecretKey)
    result.ExpiresAt = types.StringValue(cred.ExpiresAt.Format(time.RFC3339))

    // Set renew time (refresh before expiration)
    renewAt := cred.ExpiresAt.Add(-5 * time.Minute)
    resp.RenewAt = renewAt

    resp.Diagnostics.Append(resp.Result.Set(ctx, &result)...)
}
```

### Renew Method (Optional)

Refresh the ephemeral resource before expiration:

```go
func (r *TemporaryCredentialResource) Renew(ctx context.Context, req ephemeral.EphemeralResourceRenewRequest, resp *ephemeral.EphemeralResourceRenewResponse) {
    var data struct {
        Role      types.String `tfsdk:"role"`
        Duration  types.Int64  `tfsdk:"duration"`
        AccessKey types.String `tfsdk:"access_key"`
        SecretKey types.String `tfsdk:"secret_key"`
        ExpiresAt types.String `tfsdk:"expires_at"`
    }

    resp.Diagnostics.Append(req.Private.Get(ctx, &data)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Renew credential
    cred, err := r.client.RenewCredential(ctx, data.AccessKey.ValueString())
    if err != nil {
        resp.Diagnostics.AddError("Failed to renew credential", err.Error())
        return
    }

    // Update result
    data.ExpiresAt = types.StringValue(cred.ExpiresAt.Format(time.RFC3339))

    renewAt := cred.ExpiresAt.Add(-5 * time.Minute)
    resp.RenewAt = renewAt

    resp.Diagnostics.Append(resp.Result.Set(ctx, &data)...)
}
```

### Close Method

Clean up the ephemeral resource:

```go
func (r *TemporaryCredentialResource) Close(ctx context.Context, req ephemeral.EphemeralResourceCloseRequest, resp *ephemeral.EphemeralResourceCloseResponse) {
    var data struct {
        AccessKey types.String `tfsdk:"access_key"`
    }

    req.Private.Get(ctx, &data)

    // Revoke credential
    if !data.AccessKey.IsNull() {
        err := r.client.RevokeCredential(ctx, data.AccessKey.ValueString())
        if err != nil {
            resp.Diagnostics.AddWarning("Failed to revoke credential", err.Error())
            // Don't return error - resource is being cleaned up anyway
        }
    }
}
```

### Register Ephemeral Resources

```go
func (p *ExampleProvider) EphemeralResources(ctx context.Context) []func() ephemeral.EphemeralResource {
    return []func() ephemeral.EphemeralResource{
        NewTemporaryCredentialResource,
    }
}
```

### Ephemeral Resource Usage

```hcl
ephemeral "example_temporary_credential" "admin" {
  role     = "admin"
  duration = 7200
}

resource "example_server" "web" {
  name = "web-server"

  # Use ephemeral credential
  access_key = ephemeral.example_temporary_credential.admin.access_key
  secret_key = ephemeral.example_temporary_credential.admin.secret_key
}
```

### When to Use Ephemeral Resources

Use ephemeral resources for:
- **Temporary credentials** - Session tokens, temporary API keys
- **Short-lived certificates** - TLS certs for Terraform run
- **Leases** - Distributed locks, resource reservations
- **Session state** - Temporary data needed during Terraform operation

Don't use for:
- **Persistent state** - Use regular resources
- **Long-lived data** - Use regular resources with state
- **Configuration** - Use provider configuration

## Private State

Both actions and ephemeral resources support private state for internal data not exposed to users:

```go
func (r *Resource) Open(ctx context.Context, req ephemeral.EphemeralResourceOpenRequest, resp *ephemeral.EphemeralResourceOpenResponse) {
    // Store private data
    privateData := struct {
        InternalID string `json:"internal_id"`
        Token      string `json:"token"`
    }{
        InternalID: "internal-123",
        Token:      "secret-token",
    }

    resp.Diagnostics.Append(resp.Private.Set(ctx, privateData)...)

    // Set public result
    resp.Diagnostics.Append(resp.Result.Set(ctx, &publicResult)...)
}

func (r *Resource) Renew(ctx context.Context, req ephemeral.EphemeralResourceRenewRequest, resp *ephemeral.EphemeralResourceRenewResponse) {
    // Read private data
    var privateData struct {
        InternalID string `json:"internal_id"`
        Token      string `json:"token"`
    }

    resp.Diagnostics.Append(req.Private.Get(ctx, &privateData)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Use private data
    // ...
}
```

## Testing Advanced Features

### Testing Actions

```go
func TestRestartServiceAction(t *testing.T) {
    mockClient := &MockAPIClient{}
    mockClient.On("RestartService", mock.Anything, "svc-123", true).Return(&RestartResult{
        Status: "running",
    }, nil)

    action := &RestartServiceAction{client: mockClient}

    req := action.RunRequest{
        Config: /* config with service_id and force */,
    }
    resp := &action.RunResponse{}

    action.Run(context.Background(), req, resp)

    require.False(t, resp.Diagnostics.HasError())
    mockClient.AssertExpectations(t)
}
```

### Testing Ephemeral Resources

```go
func TestTemporaryCredentialResource(t *testing.T) {
    mockClient := &MockAPIClient{}
    mockClient.On("CreateTemporaryCredential", mock.Anything, "admin", 3600).Return(&Credential{
        AccessKey: "AKIATEST",
        SecretKey: "secretTest",
        ExpiresAt: time.Now().Add(1 * time.Hour),
    }, nil)

    resource := &TemporaryCredentialResource{client: mockClient}

    openReq := ephemeral.EphemeralResourceOpenRequest{
        Config: /* config with role */,
    }
    openResp := &ephemeral.EphemeralResourceOpenResponse{}

    resource.Open(context.Background(), openReq, openResp)

    require.False(t, openResp.Diagnostics.HasError())
    require.NotNil(t, openResp.RenewAt)

    // Test Close
    closeReq := ephemeral.EphemeralResourceCloseRequest{
        Private: openResp.Private,
    }
    closeResp := &ephemeral.EphemeralResourceCloseResponse{}

    resource.Close(context.Background(), closeReq, closeResp)

    mockClient.AssertExpectations(t)
}
```

## Best Practices

### Actions

- Keep actions idempotent when possible
- Validate inputs thoroughly
- Provide clear error messages
- Document expected behavior

### Ephemeral Resources

- Always implement Close to clean up resources
- Use RenewAt to refresh before expiration
- Store sensitive data in private state
- Handle renewal failures gracefully

### Security

```go
// Mark sensitive attributes
"secret_key": schema.StringAttribute{
    Computed:  true,
    Sensitive: true,  // Masked in logs
},

// Use private state for internal tokens
resp.Private.Set(ctx, privateData)  // Not visible to users
```

## External References

- [Actions Documentation](https://developer.hashicorp.com/terraform/plugin/framework/actions)
- [Ephemeral Resources Documentation](https://developer.hashicorp.com/terraform/plugin/framework/ephemeral-resources)

## Navigation

- **Previous**: [Functions](functions.md) - Provider functions
- **Next**: [Testing](testing.md) - Testing patterns
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Testing](testing.md) to learn about unit and acceptance testing patterns.*
