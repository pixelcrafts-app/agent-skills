---
name: websockets
description: Apply when implementing or reviewing real-time WebSocket features — connection auth, reconnection, event schema, room authorization. Active when craft.json features.realtime is true, or socket.io/ws/WebSocket appears in the manifest AND is actually used in source.
---

# WebSockets

> Real-time connections are long-lived and trusted-by-default — close that gap. Principles are firm; the exact numbers are examples.

## When to apply

A package manifest has `socket.io`/`ws`/`WebSocket` **and** source actually uses it (`@WebSocketGateway`, `io()`, `new WebSocket()`), or `craft.json features.realtime: true`. (`ws` alone isn't enough — many tools bundle it internally.)

## Principles (firm)

1. **Authenticate on the `connection` event** — not on first message. Unauthenticated connection → `disconnect()` immediately. An open unauthenticated socket is an info leak + resource drain.
2. **Authorize every room join.** Verify the user may access a room before `join()`; never let clients join arbitrary rooms by name.
3. **Reconnect with bounded exponential backoff.** Immediate reconnect loops cause a thundering herd on outage. After max retries, show an explicit offline state — don't retry forever.
4. **Event names live in a shared enum**, never raw strings. The enum is the contract; renames break at compile time instead of silently.
5. **Version the event schema.** The client must be able to detect an incompatible server and stop, rather than misinterpret events.

## Examples (adjust to context)

```ts
// 1 — auth on connect (NestJS)
handleConnection(client) {
  const user = this.auth.verify(client.handshake.auth.token);
  if (!user) return client.disconnect(true);
  client.data.user = user;
}

// 3 — backoff (example values: 1s→2s→4s, 3 tries)
io(url, { reconnectionAttempts: 3, reconnectionDelay: 1000, reconnectionDelayMax: 4000 });
```

## Checklist

- [ ] Token verified in the connection handler; failure → `disconnect()`
- [ ] Room join gated by a permission check
- [ ] Reconnect has bounded retries + backoff + a terminal offline state
- [ ] Event names reference a shared enum (no raw strings)
- [ ] Event schema is versioned; incompatible clients are rejected
