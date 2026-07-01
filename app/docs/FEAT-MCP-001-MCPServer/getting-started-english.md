# FEAT-MCP-001 - Connecting AI Assistants

Construction Management can be connected to AI assistants (GitHub Copilot, Copilot Studio, VS Code) so they can read and update your construction data on your behalf. An administrator sets this up once per environment.

## Turn on the AI connection

1. Run the **Set up Construction Management** assisted setup and choose the **Import demo data** option — it creates a ready-made AI connection named **Construction** and switches it on for you.
2. To confirm, search (Tell Me) for **MCP** and check that the **Construction** connection is listed and active.
3. Set it up only once — running the option again creates a second connection with the same name.

## What the assistant can do

Once connected, the assistant can:

- **Create and update** construction documents — bills of quantities, progress billing applications, subcontracts, subcontractor claims, change orders, equipment, and the project schedule.
- **Read only** (not change) the retention entries, the cost-type setup, and the linked sales and purchase orders and invoices.

## Attach it in your AI client

The construction tools are grouped together under **Construction**. Wherever your assistant lets you choose tools, use **Add Tools by API Group** and pick **Construction** to bring in the whole set at once.

### GitHub Copilot / VS Code

4. Add the Business Central connection to your assistant's settings, pointing at your environment, and sign in.
5. When it lists available tools, choose **Add Tools by API Group → Construction**.
6. Ask the assistant to work with construction data — for example, *"list the open bills of quantities"* or *"create a subcontract claim line"* — and confirm it uses the matching tool.

### Copilot Studio

7. Add the Business Central connection as a tool source, sign in, and again choose **Add Tools by API Group → Construction**.
8. Publish your agent and test a prompt that reads and (where allowed) updates construction data.

## Notes

- **What the assistant can change:** it can create and edit construction documents, but can only *read* retention, cost-type setup, and the sales/purchase orders and invoices — it can't alter posted or standard documents.
- **Permissions still apply:** the assistant acts as the signed-in user and can only do what that user is allowed to do. Give the user the appropriate construction permissions to control what the assistant can reach.
- **Disabled features stay protected:** a feature you haven't enabled can't be created or changed through the assistant.
