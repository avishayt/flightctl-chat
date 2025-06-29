# Flight Control Chat

This repo builds the images for and runs in a podman pod the following services:
- [x] flightctl-mcp
- [x] lightspeed-core + llama-stack (Same container, built separately)
- [x] [Flight Control UI](https://github.com/flightctl/flightctl-ui) - Official Flight Control web interface
- [x] inspector

# Pre-requisites

- Flight Control credentials (you will be prompted with instructions)
- Gemini API key (you will be prompted with instructions)

## Dependencies

`dnf install jq fzf`

`pip install yq`

## Submodules

```bash
git submodule init
git submodule update
```


# Usage

`./build-images.sh` - Builds all the images for the various services

`./generate.sh` - Generates the configuration files for the services (for now only lightspeed-stack config). If you didn't populate .env, it will prompt you for the required variables

`./run.sh` - Stops the previous podman pod and starts a fresh one

`./query.sh` - Example chat bot query

`./logs.sh` - Follow the logs of the podman pod

`./stop.sh` - Stops the podman pod 

`./rm.sh` - Removes the podman pod

# Access Points

- **Flight Control UI**: http://localhost:8080 - Official Flight Control web interface
- **Lightspeed Chat API**: http://localhost:8090 - Chat completion API endpoint
- **MCP Inspector**: http://localhost:6274 - MCP protocol inspector

# TODO

- [x] Add llama-stack support
- [x] Add official Flight Control UI
- [ ] Automatically connect Inspector to the MCP

