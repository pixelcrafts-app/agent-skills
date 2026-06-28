---
name: hexagonal-architecture
description: Design, implement, and refactor Ports & Adapters systems — clear domain boundaries, dependency inversion, testable use-case orchestration across TypeScript, Java, Kotlin, Go.
---

# Hexagonal Architecture (Ports & Adapters)

> Business logic is independent of frameworks, transport, and persistence. The core depends on abstract ports; adapters implement them at the edges. Apply when testability/maintainability matters, domain logic is tangled with HTTP/ORM/SDK, one use case serves multiple interfaces, or infra must be swappable.

## Layers (dependency always flows inward: Adapters → Application → Domain → nothing external)

| Layer | Contains | Cannot import |
|-------|----------|---------------|
| Domain | entities, value objects, business rules | anything framework/infra |
| Application (use cases) | orchestration, inbound/outbound port interfaces | HTTP req/res, ORM models |
| Inbound adapters | HTTP controllers, CLI, queue consumers | business logic |
| Outbound adapters | DB repos, API gateways, publishers | other adapters |
| Composition root | wires concrete adapters to use cases | (stays in one place) |

## Build

1. **Use-case boundary:** one input DTO, one output DTO — no `req`/`res`/`Context`/job-payload wrappers inside.
2. **Outbound ports first:** every side effect = a port interface modeling a *capability*, not a technology (`UserRepositoryPort`, `BillingGatewayPort`, `ClockPort`).
3. **Use case:** ports via constructor injection, validates invariants, returns plain data.
4. **Adapters at the edge:** inbound maps protocol→use-case input; outbound maps port→ORM/SDK/query. All mapping in adapters, never in use cases.
5. **Composition root:** one explicit place — no service locator, no hidden singletons.
6. **Test per boundary:** domain pure (no mocks) · use cases with fakes for outbound ports · adapters integration-tested against real infra · E2E through the inbound adapter.

```
src/features/orders/
  domain/                 Order.ts, OrderPolicy.ts
  application/ports/{inbound,outbound}/*  use-cases/CreateOrderUseCase.ts
  adapters/{inbound/http, outbound/postgres, outbound/stripe}/*
  composition/ordersContainer.ts
```

```typescript
interface OrderRepositoryPort { save(o: Order): Promise<void>; findById(id: string): Promise<Order|null>; }
class CreateOrderUseCase {
  constructor(private orders: OrderRepositoryPort, private payments: PaymentGatewayPort) {}
  async execute(input: { orderId: string; amountCents: number }) {
    const order = Order.create(input);
    const auth = await this.payments.authorize({ orderId: order.id, amountCents: order.amountCents });
    await this.orders.save(order.markAuthorized(auth.authorizationId));
    return { orderId: order.id, authorizationId: auth.authorizationId };
  }
}
// composition root wires PostgresOrderRepository + StripePaymentGateway into the use case
```

Port placement: TS `application/ports/*` · Java `application.port.in/out` · Kotlin `application.port` · Go small interfaces in the consuming `application` package; wiring in the factory module / DI container / `main.go`.

## Anti-patterns

Domain importing ORM/web/SDK types · use case reading `req`/`res`/queue metadata · returning DB rows without domain mapping · adapters calling each other (must flow through a use case) · wiring scattered across files (hidden singletons).

## Migration (strangler, no big-bang)

Pick one high-churn slice → extract a use case with explicit I/O types → wrap existing infra behind outbound ports (facade first) → move orchestration from controller/service into the use case → keep the old adapter delegating to it → characterization tests before, unit+integration after → repeat slice by slice.

## Checklist

- [ ] Domain/use-case import only internal types + port interfaces
- [ ] Every external dependency behind an outbound port; infra errors translated at the adapter boundary
- [ ] Validation at boundaries (inbound + use-case invariants); immutable transformations
- [ ] Composition root explicit, single place; use cases testable with in-memory fakes
