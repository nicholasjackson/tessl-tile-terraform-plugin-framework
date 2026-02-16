# Functions

Implement provider-defined Terraform functions for use in HCL configurations.

## Overview

Provider functions allow you to define custom Terraform functions that users can call in their configurations. Functions:
- Are pure (no side effects)
- Run during plan phase
- Can accept parameters and return values
- Are invoked with `provider::function_name()` syntax in HCL

**Example HCL usage:**
```hcl
locals {
  encoded = provider::example::base64_encode("hello world")
  parsed  = provider::example::parse_json('{"key": "value"}')
}
```

## Function Interface

```go
type Function interface {
    // Metadata returns function name
    Metadata(context.Context, FunctionMetadataRequest, *FunctionMetadataResponse)

    // Definition defines parameters and return type
    Definition(context.Context, FunctionDefinitionRequest, *FunctionDefinitionResponse)

    // Run executes the function logic
    Run(context.Context, FunctionRunRequest, *FunctionRunResponse)
}
```

## Basic Function Implementation

### Function Struct

```go
package function

import (
    "context"
    "encoding/base64"

    "github.com/hashicorp/terraform-plugin-framework/function"
)

var _ function.Function = (*Base64EncodeFunction)(nil)

type Base64EncodeFunction struct{}

func NewBase64EncodeFunction() function.Function {
    return &Base64EncodeFunction{}
}
```

### Metadata Method

```go
func (f *Base64EncodeFunction) Metadata(ctx context.Context, req function.MetadataRequest, resp *function.MetadataResponse) {
    resp.Name = "base64_encode"
}
```

**Result:** Function is `provider::example::base64_encode()` in HCL.

### Definition Method

Define parameters and return type:

```go
func (f *Base64EncodeFunction) Definition(ctx context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary:     "Encode a string to base64",
        Description: "Takes a string and returns its base64-encoded representation",
        Parameters: []function.Parameter{
            function.StringParameter{
                Name:        "input",
                Description: "The string to encode",
            },
        },
        Return: function.StringReturn{},
    }
}
```

### Run Method

Execute the function logic:

```go
func (f *Base64EncodeFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string

    // Read parameter
    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &input))
    if resp.Error != nil {
        return
    }

    // Execute logic
    encoded := base64.StdEncoding.EncodeToString([]byte(input))

    // Set result
    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, encoded))
}
```

## Register Functions

Add functions to provider:

```go
func (p *ExampleProvider) Functions(ctx context.Context) []func() function.Function {
    return []func() function.Function{
        NewBase64EncodeFunction,
        NewBase64DecodeFunction,
        NewParseJSONFunction,
    }
}
```

## Parameter Types

### String Parameter

```go
function.StringParameter{
    Name:        "text",
    Description: "Input text",
}
```

### Number Parameters

```go
function.Int64Parameter{
    Name:        "count",
    Description: "Number of items",
}

function.Float64Parameter{
    Name:        "threshold",
    Description: "Threshold value",
}
```

### Bool Parameter

```go
function.BoolParameter{
    Name:        "enabled",
    Description: "Whether feature is enabled",
}
```

### Collection Parameters

```go
function.ListParameter{
    ElementType: basetypes.StringType{},
    Name:        "items",
    Description: "List of items",
}

function.SetParameter{
    ElementType: basetypes.StringType{},
    Name:        "values",
    Description: "Set of values",
}

function.MapParameter{
    ElementType: basetypes.StringType{},
    Name:        "labels",
    Description: "Map of labels",
}
```

### Object Parameter

```go
function.ObjectParameter{
    Name:        "config",
    Description: "Configuration object",
    AttributeTypes: map[string]attr.Type{
        "host": basetypes.StringType{},
        "port": basetypes.Int64Type{},
    },
}
```

### Dynamic Parameter

For unknown types:

```go
function.DynamicParameter{
    Name:        "value",
    Description: "Any value",
}
```

## Variadic Parameters

Accept variable number of arguments:

```go
func (f *ConcatFunction) Definition(ctx context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary: "Concatenate strings",
        VariadicParameter: function.StringParameter{
            Name:        "strings",
            Description: "Strings to concatenate",
        },
        Return: function.StringReturn{},
    }
}

func (f *ConcatFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var strings []string

    // Read variadic arguments
    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &strings))
    if resp.Error != nil {
        return
    }

    // Concatenate
    result := ""
    for _, s := range strings {
        result += s
    }

    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
}
```

**Usage:**
```hcl
locals {
  message = provider::example::concat("Hello", " ", "World", "!")
}
```

## Return Types

### String Return

```go
Return: function.StringReturn{}

// In Run method
resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, "result"))
```

### Number Returns

```go
Return: function.Int64Return{}
// resp.Result.Set(ctx, int64(42))

Return: function.Float64Return{}
// resp.Result.Set(ctx, 3.14)
```

### Bool Return

```go
Return: function.BoolReturn{}
// resp.Result.Set(ctx, true)
```

### Collection Returns

```go
Return: function.ListReturn{
    ElementType: basetypes.StringType{},
}
// resp.Result.Set(ctx, []string{"a", "b", "c"})

Return: function.SetReturn{
    ElementType: basetypes.StringType{},
}
// resp.Result.Set(ctx, []string{"x", "y", "z"})

Return: function.MapReturn{
    ElementType: basetypes.StringType{},
}
// resp.Result.Set(ctx, map[string]string{"key": "value"})
```

### Object Return

```go
Return: function.ObjectReturn{
    AttributeTypes: map[string]attr.Type{
        "success": basetypes.BoolType{},
        "message": basetypes.StringType{},
    },
}

// In Run method
result := map[string]attr.Value{
    "success": basetypes.NewBoolValue(true),
    "message": basetypes.NewStringValue("Operation completed"),
}
resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
```

### Dynamic Return

```go
Return: function.DynamicReturn{}
// resp.Result.Set(ctx, anyValue)
```

## Complete Function Examples

### Parse JSON Function

```go
type ParseJSONFunction struct{}

func (f *ParseJSONFunction) Metadata(ctx context.Context, req function.MetadataRequest, resp *function.MetadataResponse) {
    resp.Name = "parse_json"
}

func (f *ParseJSONFunction) Definition(ctx context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary:     "Parse JSON string",
        Description: "Parses a JSON string and returns a dynamic value",
        Parameters: []function.Parameter{
            function.StringParameter{
                Name:        "json",
                Description: "JSON string to parse",
            },
        },
        Return: function.DynamicReturn{},
    }
}

func (f *ParseJSONFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var jsonStr string

    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &jsonStr))
    if resp.Error != nil {
        return
    }

    var parsed interface{}
    if err := json.Unmarshal([]byte(jsonStr), &parsed); err != nil {
        resp.Error = function.NewFuncError(fmt.Sprintf("Invalid JSON: %s", err.Error()))
        return
    }

    // Convert to dynamic value
    dynamicVal := convertToDynamic(parsed)
    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, dynamicVal))
}
```

### Calculate Hash Function

```go
type HashFunction struct{}

func (f *HashFunction) Metadata(ctx context.Context, req function.MetadataRequest, resp *function.MetadataResponse) {
    resp.Name = "hash"
}

func (f *HashFunction) Definition(ctx context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary: "Calculate SHA256 hash",
        Parameters: []function.Parameter{
            function.StringParameter{
                Name:        "input",
                Description: "String to hash",
            },
            function.StringParameter{
                Name:        "algorithm",
                Description: "Hash algorithm (sha256, md5)",
                AllowNullValue: true,
            },
        },
        Return: function.StringReturn{},
    }
}

func (f *HashFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string
    var algorithm *string

    resp.Error = function.ConcatFuncErrors(
        resp.Error,
        req.Arguments.Get(ctx, &input, &algorithm),
    )
    if resp.Error != nil {
        return
    }

    // Default to sha256
    algo := "sha256"
    if algorithm != nil {
        algo = *algorithm
    }

    var hash string
    switch algo {
    case "sha256":
        h := sha256.Sum256([]byte(input))
        hash = hex.EncodeToString(h[:])
    case "md5":
        h := md5.Sum([]byte(input))
        hash = hex.EncodeToString(h[:])
    default:
        resp.Error = function.NewFuncError(fmt.Sprintf("Unsupported algorithm: %s", algo))
        return
    }

    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, hash))
}
```

**Usage:**
```hcl
locals {
  hash1 = provider::example::hash("hello")
  hash2 = provider::example::hash("world", "md5")
}
```

### Filter List Function

```go
type FilterFunction struct{}

func (f *FilterFunction) Definition(ctx context.Context, req function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary: "Filter list by predicate",
        Parameters: []function.Parameter{
            function.ListParameter{
                ElementType: basetypes.StringType{},
                Name:        "list",
                Description: "List to filter",
            },
            function.StringParameter{
                Name:        "prefix",
                Description: "Prefix to filter by",
            },
        },
        Return: function.ListReturn{
            ElementType: basetypes.StringType{},
        },
    }
}

func (f *FilterFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var list []string
    var prefix string

    resp.Error = function.ConcatFuncErrors(
        resp.Error,
        req.Arguments.Get(ctx, &list, &prefix),
    )
    if resp.Error != nil {
        return
    }

    filtered := []string{}
    for _, item := range list {
        if strings.HasPrefix(item, prefix) {
            filtered = append(filtered, item)
        }
    }

    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, filtered))
}
```

**Usage:**
```hcl
locals {
  all_names = ["app-web", "app-api", "db-main", "db-cache"]
  app_names = provider::example::filter(local.all_names, "app-")
  # Result: ["app-web", "app-api"]
}
```

## Error Handling

### Function Errors

```go
func (f *Function) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string
    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &input))
    if resp.Error != nil {
        return
    }

    if input == "" {
        resp.Error = function.NewFuncError("Input cannot be empty")
        return
    }

    result, err := processInput(input)
    if err != nil {
        resp.Error = function.NewFuncError(fmt.Sprintf("Processing failed: %s", err.Error()))
        return
    }

    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
}
```

### Argument Errors

```go
// Get multiple arguments
var arg1 string
var arg2 int64
resp.Error = function.ConcatFuncErrors(
    resp.Error,
    req.Arguments.Get(ctx, &arg1, &arg2),
)
if resp.Error != nil {
    return  // Argument error details automatically included
}
```

## Testing Functions

```go
func TestBase64EncodeFunction(t *testing.T) {
    f := NewBase64EncodeFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue("hello"),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.Nil(t, resp.Error)

    var result string
    resp.Result.Get(context.Background(), &result)
    require.Equal(t, "aGVsbG8=", result)
}

func TestHashFunctionError(t *testing.T) {
    f := NewHashFunction()

    req := function.RunRequest{
        Arguments: function.NewArgumentsData([]attr.Value{
            basetypes.NewStringValue("test"),
            basetypes.NewStringValue("invalid_algo"),
        }),
    }
    resp := &function.RunResponse{
        Result: function.NewResultData(basetypes.StringType{}),
    }

    f.Run(context.Background(), req, resp)

    require.NotNil(t, resp.Error)
    require.Contains(t, resp.Error.Error(), "Unsupported algorithm")
}
```

## Best Practices

### Pure Functions

Functions should be pure (no side effects):

```go
// GOOD: Pure function
func (f *UpperFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string
    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &input))
    if resp.Error != nil {
        return
    }

    result := strings.ToUpper(input)
    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
}

// BAD: Side effects (don't do this)
func (f *LogFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var message string
    req.Arguments.Get(ctx, &message)

    log.Println(message)  // Side effect!
    // Functions should not have side effects
}
```

### Input Validation

```go
func (f *DivideFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var a, b float64
    resp.Error = function.ConcatFuncErrors(resp.Error, req.Arguments.Get(ctx, &a, &b))
    if resp.Error != nil {
        return
    }

    // Validate inputs
    if b == 0 {
        resp.Error = function.NewFuncError("Division by zero")
        return
    }

    result := a / b
    resp.Error = function.ConcatFuncErrors(resp.Error, resp.Result.Set(ctx, result))
}
```

### Clear Documentation

```go
resp.Definition = function.Definition{
    Summary:     "Convert string to uppercase",
    Description: "Takes a string and returns the uppercase version. Non-ASCII characters are handled according to Unicode rules.",
    Parameters: []function.Parameter{
        function.StringParameter{
            Name:        "input",
            Description: "The string to convert to uppercase",
        },
    },
    Return: function.StringReturn{},
}
```

## External References

- [Function Interface](https://pkg.go.dev/github.com/hashicorp/terraform-plugin-framework/function#Function)
- [Functions Guide](https://developer.hashicorp.com/terraform/plugin/framework/functions)
- [Function Parameters](https://developer.hashicorp.com/terraform/plugin/framework/functions/parameters-returns)

## Navigation

- **Previous**: [Plan Modifiers](plan-modifiers.md) - Plan modification patterns
- **Next**: [Advanced Features](advanced.md) - Actions and ephemeral resources
- **Up**: [Index](index.md) - Documentation home

---

*Continue to [Advanced Features](advanced.md) to learn about actions and ephemeral resources.*
