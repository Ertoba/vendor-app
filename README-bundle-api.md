# Bundle Offer — API Guide

Every bundle endpoint, with the parameters it takes and the response it actually returns.

Every payload below was captured from a live response, not written by hand. Ids, prices and
timestamps will differ; shapes will not.

**Base URL:** `https://your-domain.com/api/v1`

---

## Contents

1. [What a bundle is](#1-what-a-bundle-is)
2. [Conventions: headers, envelope, paging](#2-conventions)
3. [Endpoint map](#3-endpoint-map)
4. [Customer — browse](#4-customer--browse)
5. [Customer — cart](#5-customer--cart)
6. [Vendor — CRUD](#6-vendor--crud)
7. [Error reference](#7-error-reference)
8. [Screen recipes](#8-screen-recipes)

---

## 1. What a bundle is

A **bundle** is a fixed set of a store's own items sold together at one price. The vendor (or an
admin on their behalf) picks the items, each with its variations and add-ons already chosen, and
sets a discount percentage off their combined price.

Three things follow from that, and they explain most of the payloads:

**A bundle is atomic.** The customer adds, re-quantifies and removes the whole thing. There is no
endpoint to change what is inside one, and the cart never exposes its members as separate rows —
which is why the cart's bundle entry carries `"id": 0` and `"item": null`, with everything real
under `bundle_details`.

**Prices are frozen at build time.** `bundle_items.unit_price` is what the item cost the day the
bundle was built. If the menu price moves afterwards, the bundle does not — `base_price` and
`final_price` stay put. The `items[].unit_price` you see is that snapshot, not today's menu price.

**A happy hour replaces the bundle discount; it does not stack.** When a store's happy hour is
open, `discount_percentage` becomes the happy hour's rate and `is_happy_hour` turns true. The
replacement is symmetric: a happy hour weaker than the bundle's own discount will *raise* the
price. That is intended — the running promotion wins, it is not a best-of.

**Where it is switched on.** Two settings, both under Business Settings: a master switch
(`product_bundle_status`) and a per-module-type tick list (`product_bundle_modules`). The module
types that can carry a bundle are everything except `parcel`, `rental`, `ride-share` and
`service` — those have no per-item price to bundle. With the switch off, the customer endpoints
return empty lists and the vendor endpoints answer `404 bundle`.

---

## 2. Conventions

### 2.1 Headers

| Header | Who sends it | Notes |
|---|---|---|
| `moduleId` | everyone | **Required.** Numeric id or slug. |
| `zoneId` | customer | JSON array, e.g. `[1]`. Derived from lat/lng when absent. |
| `latitude` / `longitude` | customer | Used to derive the zone when `zoneId` is absent. |
| `X-localization` | everyone | Language code, e.g. `en`. Bundle names and descriptions are translated. |
| `Authorization` | logged-in customer, every vendor call | `Bearer <token>`. |
| `vendorType` | **vendor only** | `owner` or `employee`. **Required on every vendor call.** |

> **The `vendorType` trap.** It is needed on *every* vendor request, not just login. Without it
> you get `403 vendor_type`, which reads like a permissions problem and is not.

### 2.2 Auth

**§4 (browse) is public.** No token needed — a browsing visitor sees the bundles.

**§5 (cart)** needs either a bearer token **or** a `guest_id` parameter. Neither → `401 auth-001`.

**§6 (vendor)** needs the vendor's `auth_token` as a bearer token plus `vendorType`. The store is
taken from the token, never from the payload — see §6.0.

### 2.3 The envelope

Every response, success or failure, has the same four keys:

```json
{
  "identical_code": "default_200",
  "message": "Successfully fetched",
  "content": null,
  "errors": []
}
```

`content` holds the payload; `errors` is a list of `{code, message}` and is empty on success.
Read the HTTP status **and** `identical_code` — the codes are `default_200`,
`default_store_201`, `default_update_200`, `default_delete_200`, `default_404`, `forbidden_403`,
`unauthorized_401`, `unprocessable_entity_422`.

### 2.4 Paging

Listing endpoints take **`limit`** (page size) and **`offset`** (page **number**, 1-based — not a
row offset, despite the name). `limit` defaults to the panel's `default_pagination`. Responses
carry:

```json
"pagination": { "current_page": 1, "last_page": 1, "per_page": 25, "total": 1, "from": 1, "to": 1 }
```

`GET /bundle/home` is the exception: it takes `limit` only (default 10) and returns no
`pagination` block.

---

## 3. Endpoint map

| # | Method | Endpoint | Auth |
|---|---|---|---|
| 4.1 | GET | `/bundle/home` | public |
| 4.2 | GET | `/bundle/list` | public |
| 4.3 | GET | `/bundle/store-bundles` | public |
| 4.4 | GET | `/bundle/{id}` | public |
| 5.1 | POST | `/customer/cart/bundle/add` | token or `guest_id` |
| 5.2 | POST | `/customer/cart/bundle/update` | token or `guest_id` |
| 5.3 | DELETE | `/customer/cart/bundle/remove` | token or `guest_id` |
| 6.1 | GET | `/vendor/bundle/list` | vendor |
| 6.2 | GET | `/vendor/bundle/items` | vendor |
| 6.3 | GET | `/vendor/bundle/details/{id}` | vendor |
| 6.4 | POST | `/vendor/bundle/store` | vendor |
| 6.5 | POST | `/vendor/bundle/update/{id}` | vendor |
| 6.6 | POST | `/vendor/bundle/status/{id}` | vendor |
| 6.7 | DELETE | `/vendor/bundle/delete/{id}` | vendor |

`/bundle/{id}` is registered **last** in its group, so `home`, `list` and `store-bundles` are not
swallowed by it.

---

## 4. Customer — browse

All four endpoints share one object shape, so it is described once here and the sections below
show only what differs.

| Field | Type | Meaning |
|---|---|---|
| `id` | int | Bundle id. |
| `name`, `description` | string | Translated to `X-localization`. |
| `slug` | string\|null | |
| `image_full_url` | string\|null | Thumbnail. Null when the vendor uploaded none. |
| `store_id`, `store_name` | int, string | |
| `module_id` | int | |
| `start_date`, `end_date` | `Y-m-d H:i:s` | The visibility window. |
| `item_count` | int | How many items are inside. |
| `base_price` | float | Sum of the frozen item prices. |
| `bundle_price` | float | Price after the bundle's own discount. |
| `discount_percentage` | float | The bundle's rate — **or the happy hour's**, when one is open. |
| `discount_amount` | float | `base_price − final_price`. |
| `final_price` | float | **What to charge.** Use this, not `bundle_price`. |
| `is_happy_hour` | bool | True when a happy hour replaced the bundle's own discount. |
| `is_available` | bool | False when it cannot be added right now. |
| `unavailable_reason` | string\|null | Why not — display it. See §7.2. |
| `items` | array\|null | **Null on list endpoints**, populated on `/bundle/{id}`. |

> `bundle_price` and `final_price` are the same number until a happy hour is open, at which point
> `bundle_price` is the bundle's own price and `final_price` is the happy-hour one. Always bill
> `final_price`.

> **`is_available: false` is narrower than it looks on these four endpoints.** They query a
> scope that already excludes bundles that are switched off, outside their window, or in a module
> without the feature — such a bundle is simply absent from the lists, and `GET /bundle/{id}`
> answers **404 `Bundle not found`**, not a payload with a reason. So on browse, `is_available`
> can only be false for what the scope cannot see: the store being closed, or a member item being
> off, out of stock, outside its serving hours, or missing a chosen variation. The cart endpoints
> (§5) look the bundle up *without* that scope, which is why they can refuse with `This bundle has
> not started yet` where browse would have returned a 404.

### 4.1 `GET /bundle/home` — home-screen strip

| Param | In | Type | Notes |
|---|---|---|---|
| `limit` | query | int | Default 10. |
| `store_id` | query | int | Optional filter. |
| `search` | query | string | Optional, max 100 chars. |

```bash
curl -X GET "https://your-domain.com/api/v1/bundle/home?limit=2" \
  -H "moduleId: 1" \
  -H "zoneId: [1]" \
  -H "X-localization: en"
```

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "data": [
            {
                "id": 9520,
                "name": "Family Feast Box",
                "description": "Two favourites, one price",
                "slug": null,
                "image_full_url": null,
                "store_id": 3,
                "store_name": "Eorange",
                "module_id": 1,
                "start_date": "2026-09-07 11:23:57",
                "end_date": "2026-09-14 12:23:57",
                "item_count": 2,
                "base_price": 490,
                "bundle_price": 441,
                "discount_percentage": 10,
                "discount_amount": 49,
                "final_price": 441,
                "is_happy_hour": false,
                "is_available": true,
                "unavailable_reason": null,
                "items": null
            }
        ]
    },
    "errors": []
}
```

No `pagination` — this endpoint is a strip, not a page.

### 4.2 `GET /bundle/list` — paginated list

| Param | In | Type | Notes |
|---|---|---|---|
| `limit` | query | int | Page size. |
| `offset` | query | int | Page number, 1-based. |
| `store_id` | query | int | Optional filter. |
| `search` | query | string | Max 100 chars. Matches bundle name, store name and translations. |

```bash
curl -X GET "https://your-domain.com/api/v1/bundle/list?limit=2&offset=1&search=feast" \
  -H "moduleId: 1" \
  -H "zoneId: [1]"
```

Same `data[]` as §4.1, plus:

```json
"pagination": { "current_page": 1, "last_page": 1, "per_page": 2, "total": 1, "from": 1, "to": 1 }
```

### 4.3 `GET /bundle/store-bundles` — one store's bundles

| Param | In | Type | Notes |
|---|---|---|---|
| `store_id` | query | int | **Required.** |
| `limit`, `offset`, `search` | query | | As §4.2. |

```bash
curl -X GET "https://your-domain.com/api/v1/bundle/store-bundles?store_id=3" \
  -H "moduleId: 1" \
  -H "zoneId: [1]"
```

Identical payload to §4.2. Omitting `store_id` is a **404**, not a 422:

```json
{
    "identical_code": "default_404",
    "message": "Not found",
    "content": null,
    "errors": [ { "code": "store_id", "message": "Store not found" } ]
}
```

### 4.4 `GET /bundle/{id}` — detail

The only endpoint that fills `items`.

```bash
curl -X GET "https://your-domain.com/api/v1/bundle/9520" \
  -H "moduleId: 1" \
  -H "zoneId: [1]"
```

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "id": 9520,
        "name": "Family Feast Box",
        "description": "Two favourites, one price",
        "slug": null,
        "image_full_url": null,
        "store_id": 3,
        "store_name": "Eorange",
        "module_id": 1,
        "start_date": "2026-09-07 11:23:57",
        "end_date": "2026-09-14 12:23:57",
        "item_count": 2,
        "base_price": 490,
        "bundle_price": 441,
        "discount_percentage": 10,
        "discount_amount": 49,
        "final_price": 441,
        "is_happy_hour": false,
        "is_available": true,
        "unavailable_reason": null,
        "items": [
            {
                "item_id": 101,
                "name": "Ferrero Rocher Chocolate Box",
                "image_full_url": null,
                "unit_price": 390,
                "quantity": 1,
                "variation_summary": "",
                "variations": [],
                "add_on_ids": [],
                "add_on_qtys": []
            },
            {
                "item_id": 106,
                "name": "Blue Grapes",
                "image_full_url": "https://mart.test/storage/app/public/product/2022-03-22-6239d029d1dc8.png",
                "unit_price": 100,
                "quantity": 1,
                "variation_summary": "",
                "variations": [],
                "add_on_ids": [],
                "add_on_qtys": []
            }
        ]
    },
    "errors": []
}
```

`variation_summary` is a ready-to-render string — `"Large, Extra cheese"` — built from
`variations`. Render the summary; the raw arrays are there if you need them.

An unknown id is `404 bundle` / `"Bundle not found"`.

---

## 5. Customer — cart

Three verbs of their own, because a bundle is atomic. The item-row endpoints
(`cart/update`, `cart/remove-item`) address a single row by id and **must not** be pointed at a
bundle member.

All three take `guest_id` when there is no bearer token.

### 5.1 `POST /customer/cart/bundle/add`

| Param | In | Type | Notes |
|---|---|---|---|
| `bundle_id` | body | int | **Required.** |
| `quantity` | body | int | Min 1, default 1. |
| `guest_id` | body | string | Required when unauthenticated. |

```bash
curl -X POST "https://your-domain.com/api/v1/customer/cart/bundle/add" \
  -H "Authorization: Bearer <customer-token>" \
  -H "moduleId: 1" \
  -H "zoneId: [1]" \
  -H "Content-Type: application/json" \
  -d '{"bundle_id": 9520, "quantity": 2}'
```

**201:**

```json
{
    "identical_code": "default_store_201",
    "message": "Successfully created",
    "content": {
        "bundle_group_id": "354b8677-8b3e-43e8-a05a-47e7667aa2aa",
        "quantity": 2,
        "store_id": 3,
        "data": [
            {
                "id": 0,
                "module_id": 1,
                "store_id": 3,
                "price": 441,
                "quantity": 2,
                "variation": [],
                "add_on_ids": [],
                "add_on_qtys": [],
                "item": null,
                "bogo_details": null,
                "bundle_details": {
                    "bundle_group_id": "354b8677-8b3e-43e8-a05a-47e7667aa2aa",
                    "bundle_id": 9520,
                    "name": "Family Feast Box",
                    "image_full_url": null,
                    "start_date": "2026-09-07 11:23:57",
                    "end_date": "2026-09-14 12:23:57",
                    "quantity": 2,
                    "base_price": 490,
                    "bundle_price": 441,
                    "discount_percentage": 10,
                    "discount_amount": 49,
                    "final_price": 441,
                    "is_happy_hour": false,
                    "total_final_price": 882,
                    "total_discount_amount": 98,
                    "is_available": true,
                    "unavailable_reason": null,
                    "items": [
                        {
                            "item_id": 101,
                            "name": "Ferrero Rocher Chocolate Box",
                            "image_full_url": null,
                            "unit_price": 390,
                            "variation_summary": ""
                        },
                        {
                            "item_id": 106,
                            "name": "Blue Grapes",
                            "image_full_url": "https://mart.test/storage/app/public/product/2022-03-22-6239d029d1dc8.png",
                            "unit_price": 100,
                            "variation_summary": ""
                        }
                    ]
                }
            }
        ],
        "pagination": { "current_page": 1, "last_page": 1, "per_page": 25, "total": 2, "from": 1, "to": 2 }
    },
    "errors": []
}
```

**Keep the `bundle_group_id`** — it is the handle for update and remove. A second add of the same
bundle produces a *second* group with its own id.

**Reading the cart entry.** One entry per bundle group, folded from the underlying rows:

- `id` is `0` and `item` is `null` — the entry is not a cart row, so do not send it to the
  item-row endpoints.
- `price` and `quantity` at the top level are the bundle's unit price and copy count.
- Everything else lives under `bundle_details`. `total_final_price` = `final_price × quantity`;
  `total_discount_amount` = `discount_amount × quantity`.
- `pagination.total` counts the **underlying cart rows** (2 items here), not the entries — so a
  cart of one bundle shows `"total": 2` beside a single entry. Page on the entries you render.

The same entry appears in `GET /customer/cart/list` and `GET /customer/cart/get-all`; nothing
else in those responses changes.

### 5.2 `POST /customer/cart/bundle/update`

Changes how many copies the cart holds. Nothing else about a bundle is editable.

| Param | In | Type | Notes |
|---|---|---|---|
| `bundle_group_id` | body | string | **Required.** From the add response. |
| `quantity` | body | int | Min 1. |
| `guest_id` | body | string | Required when unauthenticated. |

```bash
curl -X POST "https://your-domain.com/api/v1/customer/cart/bundle/update" \
  -H "Authorization: Bearer <customer-token>" \
  -H "moduleId: 1" \
  -H "Content-Type: application/json" \
  -d '{"bundle_group_id": "354b8677-8b3e-43e8-a05a-47e7667aa2aa", "quantity": 3}'
```

Returns `default_update_200` with the same body as §5.1, re-priced. The rows are deleted and
re-inserted in one transaction, so the group id survives.

### 5.3 `DELETE /customer/cart/bundle/remove`

| Param | In | Type | Notes |
|---|---|---|---|
| `bundle_group_id` | body | string | **Required.** |
| `guest_id` | body | string | Required when unauthenticated. |

```bash
curl -X DELETE "https://your-domain.com/api/v1/customer/cart/bundle/remove" \
  -H "Authorization: Bearer <customer-token>" \
  -H "moduleId: 1" \
  -H "Content-Type: application/json" \
  -d '{"bundle_group_id": "354b8677-8b3e-43e8-a05a-47e7667aa2aa"}'
```

```json
{
    "identical_code": "default_delete_200",
    "message": "Successfully deleted",
    "content": {
        "data": [],
        "pagination": { "current_page": 1, "last_page": 1, "per_page": 25, "total": 0, "from": null, "to": null }
    },
    "errors": []
}
```

Removes every row in the group. An unknown group is `404 bundle_group_id`.

> **Orders holding a bundle cannot be edited.** Once placed, an order with a bundle line refuses
> edit on the admin panel, the vendor panel and the API. The vendor order payload carries
> `can_edit` — hide the edit affordance when it is false. It also goes false for the pre-existing
> reasons: a non-pending order, a non-cash payment method, a prescription order, a referral bonus
> or flash-sale discount, or any recorded payment.

---

## 6. Vendor — CRUD

### 6.0 What the token decides

The store comes from the vendor's token, never from the request. `store_id` is still required in
the create payload and is checked against the token's store — a mismatch is `403`. On update it
is pinned to the bundle's existing store: a bundle never moves. Another store's bundle is `404`,
not `403`, so the API does not confirm it exists.

These endpoints carry **no `promotion-module` middleware**. The switch is the Business Settings
pair from §1, asked inside the controller — so the panel, this API and the cart are held to one
rule rather than three.

### 6.1 `GET /vendor/bundle/list`

| Param | In | Type | Notes |
|---|---|---|---|
| `limit`, `offset` | query | int | As §2.4. |
| `search` | query | string | Bundle name and translations. |

```bash
curl -X GET "https://your-domain.com/api/v1/vendor/bundle/list?limit=2&offset=1" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1"
```

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "data": [
            {
                "id": 9520,
                "name": "Family Feast Box",
                "description": "Two favourites, one price",
                "image_full_url": null,
                "start_date": "2026-09-07 11:23:57",
                "end_date": "2026-09-14 12:23:57",
                "base_price": 490,
                "discount_percentage": 10,
                "discounted_price": 441,
                "status": 1,
                "created_by": "admin",
                "visibility_status": "running",
                "item_count": 2,
                "items": null
            }
        ],
        "pagination": { "current_page": 1, "last_page": 1, "per_page": 2, "total": 1, "from": 1, "to": 1 }
    },
    "errors": []
}
```

The vendor shape differs from the customer one: `discounted_price` rather than `final_price`, and
no happy-hour fields — a vendor is looking at what they built, not at today's price. Two fields
are vendor-only:

| Field | Values | Meaning |
|---|---|---|
| `status` | `0` / `1` | The vendor's own on/off switch. |
| `created_by` | `admin` / `vendor` | Who built it. Admin-built bundles are still fully editable by the store. |
| `visibility_status` | `running`, `scheduled`, `ended`, `not_visible` | Status **and** window folded into one label — render this, do not recompute it. |

### 6.2 `GET /vendor/bundle/items` — the picker catalogue

The store's menu, shaped for a bundle builder.

| Param | In | Type | Notes |
|---|---|---|---|
| `search` | query | string | Optional. |

```bash
curl -X GET "https://your-domain.com/api/v1/vendor/bundle/items?search=grapes" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1"
```

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "items": [
            {
                "id": 106,
                "name": "Blue Grapes",
                "category_name": "Shrimp",
                "description": "Blue Concord are sweet, juicy and easy to grow.",
                "image_full_url": "https://mart.test/storage/app/public/product/2022-03-22-6239d029d1dc8.png",
                "price": 100,
                "discounted_price": 80,
                "discount": 20,
                "discount_type": "percent",
                "veg": 0,
                "maximum_cart_quantity": null,
                "variations": [],
                "choice_options": [],
                "variation_combinations": [],
                "uses_food_variations": false,
                "stock": 999,
                "module_has_stock": true,
                "add_ons": [],
                "is_available": true
            }
        ]
    },
    "errors": []
}
```

Two things to know about this payload:

**Unavailable items are returned, not filtered out.** They come back flagged
`"is_available": false`. A vendor who cannot find an item cannot tell whether it is missing or
ineligible, so grey it with a badge rather than hiding it.

**Both variation shapes are sent, and `uses_food_variations` says which to render.** 6amMart has
two, and an item may carry either:

- `uses_food_variations: true` → read **`variations`**: named groups of labelled options whose
  `optionPrice` **adds** to the base.
- `uses_food_variations: false` → read **`choice_options`** and **`variation_combinations`**: the
  chosen combination joins with `-` into a row whose price **replaces** the base and which carries
  its own `stock`.

Rendering only the food shape leaves a grocery or pharmacy item with no options and prices it at
base — whatever the customer would actually have paid.

### 6.3 `GET /vendor/bundle/details/{id}`

Same object as §6.1 with `items` filled:

```json
"items": [
    {
        "item_id": 101,
        "name": "Ferrero Rocher Chocolate Box",
        "image_full_url": null,
        "unit_price": 390,
        "variation_summary": "",
        "variations": [],
        "add_on_ids": [],
        "add_on_qtys": []
    }
]
```

`unit_price` is the frozen snapshot, so it may differ from today's `price` in §6.2. That is not a
bug — it is what the bundle was priced on.

### 6.4 `POST /vendor/bundle/store`

**`multipart/form-data`** — there is a file.

| Param | Type | Rules |
|---|---|---|
| `lang[]` | array | **Required.** Locales, positional with `name[]`/`description[]`. One entry must be `default`. |
| `name[]` | array | **Required.** Max 80 chars per entry. |
| `description[]` | array | Optional. Max 1000 chars per entry. |
| `image` | file | **Required on create.** Standard image rules and size cap. |
| `store_id` | int | **Required.** Must match the token's store. |
| `start_date` | datetime | **Required.** Not in the past. |
| `end_date` | datetime | **Required.** After `start_date`, and not in the past. |
| `discount_percentage` | numeric | **Required.** `0`–`99`. |
| `items` | array | **Required.** 2–50 entries. |
| `items[].item_id` | int | **Required.** Must belong to `store_id`. |

```bash
curl -X POST "https://your-domain.com/api/v1/vendor/bundle/store" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1" \
  -F "lang[]=default" \
  -F "name[]=Weekend Combo" \
  -F "description[]=Two of our best sellers at one price" \
  -F "store_id=3" \
  -F "start_date=2026-09-08 12:23" \
  -F "end_date=2026-10-07 12:23" \
  -F "discount_percentage=15" \
  -F "items[0][item_id]=101" \
  -F "items[1][item_id]=106" \
  -F "image=@combo.png"
```

**201:**

```json
{
    "identical_code": "default_store_201",
    "message": "Successfully created",
    "content": {
        "id": 9521,
        "name": "Weekend Combo",
        "description": "Two of our best sellers at one price",
        "image_full_url": "https://mart.test/storage/app/public/bundle/2026-09-07-6a9e587da7443.webp",
        "start_date": "2026-09-08 12:23:00",
        "end_date": "2026-10-07 12:23:00",
        "base_price": 490,
        "discount_percentage": 15,
        "discounted_price": 416.5,
        "status": 1,
        "created_by": "vendor",
        "visibility_status": "scheduled",
        "item_count": 2,
        "items": [ … ]
    },
    "errors": []
}
```

`base_price` and `discounted_price` are **computed server-side** from the items and the
percentage — do not send them. Additional locales go in as parallel entries:
`lang[]=default&lang[]=bn` with `name[]=Weekend Combo&name[]=সাপ্তাহিক কম্বো`.

> **Validation failures return `403`, not `422`,** with the field in `errors[].code`. See §7.1.

### 6.5 `POST /vendor/bundle/update/{id}`

Same payload and rules as §6.4, with two differences: `image` is **optional** (omit it to keep the
existing one), and `store_id` must equal the bundle's current store — a bundle stays with the
store it was built for.

```bash
curl -X POST "https://your-domain.com/api/v1/vendor/bundle/update/9521" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1" \
  -F "lang[]=default" \
  -F "name[]=Weekend Combo" \
  -F "store_id=3" \
  -F "start_date=2026-09-08 12:23" \
  -F "end_date=2026-10-07 12:23" \
  -F "discount_percentage=25" \
  -F "items[0][item_id]=101" \
  -F "items[1][item_id]=106"
```

Returns `default_update_200` with the re-priced bundle (`discounted_price` `416.5` → `367.5` in
the example above).

> **An update empties every cart holding this bundle.** The items and prices may have changed, so
> the old rows are dropped rather than silently re-priced. Expect customers to lose it from their
> cart.

### 6.6 `POST /vendor/bundle/status/{id}`

| Param | In | Type | Notes |
|---|---|---|---|
| `status` | body | boolean | **Required.** `1` on, `0` off. |

```bash
curl -X POST "https://your-domain.com/api/v1/vendor/bundle/status/9521" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1" \
  -H "Content-Type: application/json" \
  -d '{"status": 0}'
```

```json
{
    "identical_code": "default_update_200",
    "message": "Successfully updated",
    "content": null,
    "errors": []
}
```

Switching **off** also clears the bundle from every cart holding it.

### 6.7 `DELETE /vendor/bundle/delete/{id}`

```bash
curl -X DELETE "https://your-domain.com/api/v1/vendor/bundle/delete/9521" \
  -H "Authorization: Bearer <vendor-auth-token>" \
  -H "vendorType: owner" \
  -H "moduleId: 1"
```

```json
{
    "identical_code": "default_delete_200",
    "message": "Successfully deleted",
    "content": null,
    "errors": []
}
```

Soft delete — items and translations are kept for a restore. Every cart holding it is cleared.
Orders already placed are untouched; they carry their own frozen copy.

---

## 7. Error reference

### 7.1 By status

| Status | `identical_code` | When |
|---|---|---|
| 401 | `unauthorized_401` | Cart with neither token nor `guest_id` (`auth-001`); vendor call with no bearer token. |
| 403 | `forbidden_403` | **Vendor validation failure** — field name in `errors[].code`. Also missing `vendorType` (`vendor_type`), and a create whose `store_id` is not the token's store. |
| 403 | `forbidden_403` | Cart add/update the bundle cannot accept right now — `errors[].code` is `bundle`, the message is the reason from §7.2. |
| 404 | `default_404` | Unknown bundle (`bundle`); unknown cart group (`bundle_group_id`); `store-bundles` without `store_id` (`store_id`); the feature switched off for this module (`bundle`). |
| 422 | `unprocessable_entity_422` | Customer-side query validation, e.g. `cart/list` without `store_id`. |

The vendor endpoints return **403 for validation**, not 422 — a client that only branches on 422
will read a bad payload as a permissions error:

```json
{
    "identical_code": "forbidden_403",
    "message": "Permission denied",
    "content": null,
    "errors": [ { "code": "items", "message": "A bundle needs at least 2 items" } ]
}
```

Other messages from the same table: `Add the items this bundle contains`, `A bundle cannot hold
more than 50 items`, `The end date must be later than the start date`, `The discount cannot reach
99 percent`, `An item was chosen that this store does not sell`, `A bundle stays with the store it
was built for`, `The bundle cannot start in the past`.

### 7.2 `unavailable_reason`

One rule computes both the `unavailable_reason` field on browse responses and the 403 message on
cart add/update, so the wording is identical either way. It is computed for the **quantity being
requested**, so a bundle can list as available and still be refused at a higher quantity.

| Reason | Cause | Where it can appear |
|---|---|---|
| `This bundle is no longer available` | Switched off, module unticked, or fewer than 2 items left. | cart only |
| `This bundle has not started yet` | Before `start_date`. | cart only |
| `This bundle has already ended` | After `end_date`. | cart only |
| *(scheduled-order variants of the two above)* | A scheduled order falls outside the window. | cart only |
| *(store-unavailable message)* | Store closed or deactivated. | browse + cart |
| `<item> is no longer available` | A member item was deleted. | browse + cart |
| `<item> Is currently unavailable` | A member item is off or out of stock. | browse + cart |
| *(serving-hours / variation messages)* | A member item is outside its serving hours, or a chosen variation no longer exists. | browse + cart |

"cart only" reasons never reach a browse response — see the note in §4. Captured examples:

```json
"unavailable_reason": "Ferrero Rocher Chocolate Box Is currently unavailable"
```

```json
{ "code": "bundle", "message": "This bundle has already ended" }
```

Always render `unavailable_reason` rather than a generic message — it names the item at fault.

---

## 8. Screen recipes

**Home strip.** `GET /bundle/home?limit=6`. Show `image_full_url`, `name`, `final_price` struck
through against `base_price`, and `discount_percentage` as a badge. Grey the card and show
`unavailable_reason` when `is_available` is false.

**Bundle detail.** `GET /bundle/{id}`. `items[]` is filled here — list each with its
`variation_summary`. Bill `final_price`, not `bundle_price`. If `is_happy_hour` is true, label the
discount as the happy hour's, not the bundle's.

**Store page.** `GET /bundle/store-bundles?store_id=…`, paged with `limit`/`offset`.

**Add to cart.** `POST /customer/cart/bundle/add` with `bundle_id` and `quantity`. Store the
returned `bundle_group_id` against the rendered row — it is the only handle for the next two
calls. On 403, show the message: it is the `unavailable_reason`.

**Cart screen.** Render entries whose `bundle_details` is non-null as a single card, not as
member rows; `item` is null and `id` is 0 on those entries. Quantity stepper → `bundle/update`;
delete → `bundle/remove`. Re-check `bundle_details.is_available` on every load — a bundle can
expire while the cart sits there.

**Vendor builder.** `GET /vendor/bundle/items` for the picker (respect `uses_food_variations`),
then `POST /vendor/bundle/store` as multipart. Read `base_price`/`discounted_price` back from the
response rather than computing them client-side. Warn before saving an update — it empties every
cart holding the bundle.
