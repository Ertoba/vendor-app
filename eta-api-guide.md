# ETA in the APIs — customer, vendor, deliveryman

How the estimated delivery time reaches each app, which endpoints carry it, and a runnable curl
for every one of them.

The estimate itself is built by `app/Services/Order/EtaService.php`. How it is calculated is
documented in [`delivery-zone-suite-S7b-eta-estimate.md`](delivery-zone-suite-S7b-eta-estimate.md);
this file is the API-side reference.

---

## 1. Before anything returns an ETA

**An ETA is only produced where an admin configured one.** No configuration for the order's
`(zone, module)` pair — or one switched off — and every endpoint below returns `"eta": null`.
There is no default fallback, on purpose: an ETA is a promise, and the platform does not make one
it was not configured to make.

Set one up at **Admin → Delivery Management → ETA Configuration**
(`admin/business-settings/zone/eta-configuration/create`), or straight from tinker:

```bash
php artisan tinker --execute="
\$c = \App\Models\EtaConfiguration::create([
  'name' => 'Zone 1 ETA',
  'zone_id' => 1,
  'calculation_method' => 'distance_based',   // or 'fixed_delivery_time'
  'minimum_delivery_time' => 20,              // floor, minutes
  'preparation_buffer' => 10,                 // minutes
  'transit_buffer' => 5,                      // minutes
  'time_gap' => 15,                           // how wide the range is, minutes
  'status' => 1,
]);
\$c->modules()->sync([1]);                     // module ids this setup covers
echo \$c->id;
"
```

An order also has to be **`order_type = delivery`** and **not finished**. These statuses return
`null`: `delivered`, `canceled`, `failed`, `refunded`, `refund_requested`,
`refund_request_canceled`. So do `take_away` and `parcel` orders.

---

## 2. The `eta` object

Every surface returns exactly the same shape.

| Field | Type | Meaning |
|---|---|---|
| `min` | int | Near end of the window. **Always minutes**, whatever `text` reads. |
| `max` | int | Far end of the window. **Always minutes.** |
| `unit` | string | Translated unit for `min`/`max` — always the minute key (`min`). |
| `text` | string | Ready-to-print range, **scaled**: `"25 - 40 min"`, `"2 - 3 hr"`, `"3 - 5 days"`. When `overdue` it becomes `"Any minute now"` and carries no numbers. |
| `overdue` | bool | The whole window has passed. Additive — style the row differently rather than inferring it from the clock. |
| `from` | string | Near end as a clock time, `04:37 PM`. |
| `to` | string | Far end as a clock time. |
| `window` | string | `"04:37 PM - 04:52 PM"`, collapsed to one time when both ends match. |
| `from_at` | string | Near end, ISO 8601 with offset. Use this for arithmetic, not `from`. |
| `to_at` | string | Far end, ISO 8601 with offset. |
| `timezone` | string | The panel's timezone, e.g. `Asia/Dhaka`. Every order timestamp is written in it. |
| `stage` | string | `before_processing` while the buffer stands in for the kitchen; `processing` once the store has written its own `processing_time`. |

`null` is a real answer, not an error. Clients must render nothing rather than a placeholder time.

---

## 3. Authentication per surface

The three apps authenticate in three different ways. This is the most common reason a curl comes
back `401`.

| Surface | Credential | How it is sent | Extra headers |
|---|---|---|---|
| Customer | Passport bearer token | `Authorization: Bearer <token>` | `moduleId` **required** |
| Vendor | `vendors.auth_token` | `Authorization: Bearer <token>` | `vendorType: owner` (or `employee`) **required** |
| Deliveryman | `delivery_men.auth_token` | **`token` query/body parameter — not a header** | — |

`X-localization: en` is optional everywhere and only changes the translated `unit` / `text`.

The apps also send `zoneId` on every call. **The order endpoints do not read it** — it is kept in the
curls below only because that is what the real traffic looks like, and dropping it changes nothing.

### Getting each token

```bash
BASE=http://mart_copy.test/api/v1        # change to your host

# Customer
curl -s -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"login_type":"manual","field_type":"phone","email_or_phone":"+8801999527952","password":"<password>"}'

# Vendor  → content.token
curl -s -X POST "$BASE/auth/vendor/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"Grocery.store1@demo.com","password":"<password>","vendor_type":"owner"}'

# Deliveryman  → content.token
curl -s -X POST "$BASE/auth/delivery-man/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+8801700000000","password":"<password>","type":"is_delivery"}'
```

Export them once and the curls below run as written:

```bash
BASE=http://mart_copy.test/api/v1
CUSTOMER_TOKEN=<passport token>
VENDOR_TOKEN=<vendors.auth_token>
DM_TOKEN=<delivery_men.auth_token>
ORDER_ID=100183
```

---

## 4. Customer API

Three endpoints carry `eta`.

| Endpoint | Method | Where `eta` sits |
|---|---|---|
| `customer/order/track` | GET | `content.eta` |
| `customer/order/list` | GET | `content.data[].eta` |
| `customer/order/running-orders` | GET | `content.data[].eta` |

All three sit behind `ModuleCheckMiddleware`, so **`moduleId` is a required header** — without it
you get a 403 `Module id required`, not an ETA.

### 4.1 Track an order — the main one

```bash
curl -s -G "$BASE/customer/order/track" \
  --data-urlencode "order_id=$ORDER_ID" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN" \
  -H "moduleId: 1" \
  -H "zoneId: [1]" \
  -H "X-localization: en"
```

Response (trimmed; captured live against order `100183`):

```json
{
  "identical_code": "default_200",
  "message": "Successfully fetched",
  "content": {
    "id": 100183,
    "user_id": 46,
    "eta": {
      "min": 0,
      "max": 5,
      "unit": "min",
      "text": "Any minute now",
      "overdue": true,
      "from": "04:02 PM",
      "to": "04:07 PM",
      "window": "04:02 PM - 04:07 PM",
      "from_at": "2026-09-05T16:02:32+06:00",
      "to_at": "2026-09-05T16:07:32+06:00",
      "timezone": "Asia/Dhaka",
      "stage": "before_processing"
    },
    "order_status": "pending",
    "order_amount": 774.1,
    "min_delivery_time": 120,
    "max_delivery_time": 180,
    "...": "the rest of the order"
  },
  "errors": []
}
```

> `min_delivery_time` / `max_delivery_time` are the **store's own** advertised window, not the
> ETA. They are unrelated fields that happen to sit next to it.

**Guest tracking.** Without a login, `track` needs `guest_id` and `contact_number`, and it only
resolves orders actually placed as a guest (`is_guest = 1`) whose delivery address carries that
number:

```bash
curl -s -G "$BASE/customer/order/track" \
  --data-urlencode "order_id=100200" \
  --data-urlencode "contact_number=8801999527952" \
  --data-urlencode "guest_id=1" \
  -H "moduleId: 1"
```

### 4.2 Order list

`type` is one of `running`, `previous` or `all` (anything else falls back to `previous`). Only
`running` rows realistically carry an ETA — finished orders return `null` by design.

```bash
curl -s -G "$BASE/customer/order/list" \
  --data-urlencode "type=running" \
  --data-urlencode "limit=10" \
  --data-urlencode "offset=1" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN" \
  -H "moduleId: 1" \
  -H "zoneId: [1]"
```

```json
{
  "content": {
    "data": [
      { "id": 100187, "order_status": "pending", "eta": { "min": 0, "max": 5, "text": "Any minute now", "overdue": true, "...": "..." } }
    ],
    "pagination": { "...": "..." },
    "type": "running",
    "module_id": "1",
    "all_count": 4, "previous_count": 0, "running_count": 4
  }
}
```

### 4.3 Running orders

```bash
curl -s -G "$BASE/customer/order/running-orders" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN" \
  -H "moduleId: 1" \
  -H "zoneId: [1]"
```

Same `content.data[].eta` shape as the list.

### 4.4 Customer endpoints that do NOT carry an ETA

- `customer/order/details` — returns the item rows, not the order envelope. No `eta`.
- `customer/order/all-running-orders` — the compact activity feed. No `eta`.
- `customer/order/last` — order cards. No `eta`.
- A **parcel** order fetched through `customer/order/details` does emit an `eta` key, but it is
  always `null`: parcels are not `order_type = delivery`.

---

## 5. Vendor API

| Endpoint | Method | Where `eta` sits |
|---|---|---|
| `vendor/order` | GET | `content.eta` |
| `vendor/current-orders` | GET | `content.data[].eta` |
| `vendor/all-orders` | GET | `content.data[].eta` |
| `vendor/update-order` | PUT | `content.eta` on the updated order |

`vendor/completed-orders` and `vendor/canceled-orders` deliberately carry no ETA — those orders are
finished and there is nothing left to estimate.

### 5.1 Single order

```bash
curl -s -G "$BASE/vendor/order" \
  --data-urlencode "order_id=$ORDER_ID" \
  -H "Authorization: Bearer $VENDOR_TOKEN" \
  -H "vendorType: owner" \
  -H "X-localization: en"
```

Captured live:

```json
{
  "identical_code": "default_200",
  "message": "Successfully fetched",
  "content": {
    "id": 100183,
    "order_status": "pending",
    "eta": {
      "min": 0,
      "max": 5,
      "unit": "min",
      "text": "Any minute now",
      "overdue": true,
      "from": "04:03 PM",
      "to": "04:08 PM",
      "window": "04:03 PM - 04:08 PM",
      "from_at": "2026-09-05T16:03:25+06:00",
      "to_at": "2026-09-05T16:08:25+06:00",
      "timezone": "Asia/Dhaka",
      "stage": "before_processing"
    },
    "...": "the rest of the order"
  },
  "errors": []
}
```

### 5.2 Current orders / all orders

```bash
curl -s -G "$BASE/vendor/current-orders" \
  -H "Authorization: Bearer $VENDOR_TOKEN" \
  -H "vendorType: owner"

curl -s -G "$BASE/vendor/all-orders" \
  --data-urlencode "limit=10" \
  --data-urlencode "offset=1" \
  -H "Authorization: Bearer $VENDOR_TOKEN" \
  -H "vendorType: owner"
```

Each row in `content.data[]` carries its own `eta`.

### 5.3 Order edit response

The edit response re-reads the order and re-attaches the ETA, so the app can refresh the promise in
the same round trip.

```bash
curl -s -X PUT "$BASE/vendor/update-order" \
  -H "Authorization: Bearer $VENDOR_TOKEN" \
  -H "vendorType: owner" \
  -H "Content-Type: application/json" \
  -d '{
        "order_id": 100183,
        "carts": [
          { "item_id": 1, "quantity": 2, "variation": [], "add_on_ids": [], "add_on_qtys": [] }
        ]
      }'
```

> Sending this mutates a real order. Run it against a throwaway order.

---

## 6. Deliveryman API

**The deliveryman token is a request parameter, not a header.**

| Endpoint | Method | Where `eta` sits |
|---|---|---|
| `delivery-man/order` | GET | `content.eta` |
| `delivery-man/current-orders` | GET | `content.data[].eta` |
| `delivery-man/latest-orders` | GET | `content.data[].eta` |
| `delivery-man/all-orders` | GET | `content.data[].eta` |

### 6.1 Single order

```bash
curl -s -G "$BASE/delivery-man/order" \
  --data-urlencode "order_id=100126" \
  --data-urlencode "token=$DM_TOKEN" \
  -H "X-localization: en"
```

Captured live:

```json
{
  "identical_code": "default_200",
  "message": "Successfully fetched",
  "content": {
    "id": 100126,
    "order_status": "picked_up",
    "eta": {
      "min": 0,
      "max": 5,
      "unit": "min",
      "text": "Any minute now",
      "overdue": true,
      "from": "04:04 PM",
      "to": "04:09 PM",
      "window": "04:04 PM - 04:09 PM",
      "from_at": "2026-09-05T16:04:19+06:00",
      "to_at": "2026-09-05T16:09:19+06:00",
      "timezone": "Asia/Dhaka",
      "stage": "before_processing"
    },
    "...": "the rest of the order"
  },
  "errors": []
}
```

### 6.2 Lists

```bash
curl -s -G "$BASE/delivery-man/current-orders" \
  --data-urlencode "token=$DM_TOKEN"

curl -s -G "$BASE/delivery-man/latest-orders" \
  --data-urlencode "token=$DM_TOKEN"

curl -s -G "$BASE/delivery-man/all-orders" \
  --data-urlencode "token=$DM_TOKEN" \
  --data-urlencode "order_status=picked_up"
```

A **real null** from `current-orders` on this install — order `100126` (zone 1, module 1) has a
configuration and returns an ETA, while order `100065` (zone 1, **module 4**) has none:

```json
{ "id": 100065, "order_status": "picked_up", "eta": null }
```

Same zone, different module, and the module is what is missing from the setup. This is the single
most common "why is my ETA null" cause.

### 6.3 Deliveryman endpoints that do NOT carry an ETA

- `delivery-man/order-details` — item rows only.
- `delivery-man/orders-count` — counters only.

---

## 7. What the numbers look like in each state

Real output from `EtaService`, order in zone 1 / module 1, store quoting `2-3 hours`, setup
`distance_based` with minimum 20 / prep 10 / transit 5 / gap 15.

**A. No `delivery_duration` on the order** — falls back to the store's own delivery time
(120–180 min) plus the two buffers:

```json
{ "min": 135, "max": 195, "unit": "min", "text": "2 - 3 hr", "overdue": false,
  "window": "06:20 PM - 07:20 PM", "stage": "before_processing" }
```

**B. `delivery_duration = 600` (10 min from the map)** — 10 travel + 10 prep + 5 transit = 25,
widened by the 15-minute gap:

```json
{ "min": 25, "max": 40, "unit": "min", "text": "25 - 40 min", "overdue": false,
  "window": "04:30 PM - 04:45 PM", "stage": "before_processing" }
```

**C. Store marked it processing with `processing_time = 25`** — the store's own figure replaces
the preparation buffer, and `stage` flips:

```json
{ "min": 40, "max": 55, "unit": "min", "text": "40 - 55 min", "overdue": false,
  "window": "04:45 PM - 05:00 PM", "stage": "processing" }
```

**D. The window has passed** — both ends move to now and the wording changes:

```json
{ "min": 0, "max": 5, "unit": "min", "text": "Any minute now", "overdue": true,
  "window": "04:02 PM - 04:07 PM", "stage": "before_processing" }
```

**E. Nothing configured for the order's (zone, module)**:

```json
{ "eta": null }
```

Notice that `delivery_duration` only reaches the order when the **customer app** posts it at
placement (seconds, from the map API). Web checkout, POS and admin orders never send it and always
take path A — that is the designed fallback, not a bug.

---

## 8. Troubleshooting

| Symptom | Cause |
|---|---|
| `403 Module id required` | Customer endpoints need the `moduleId` header. |
| `401 Unauthorized` on a customer call | Missing/expired `Authorization`, or a guest call without `guest_id`. |
| `403 Vendor type required` | Vendor calls need the `vendorType: owner` header. |
| `401` on a deliveryman call | The token went in as a header. It must be the `token` **parameter**. |
| `eta` is `null` on a live delivery order | No active `EtaConfiguration` for that `(zone_id, module_id)` — check the module, not just the zone. |
| `eta` missing from the payload entirely | You are on an endpoint from the "does NOT carry" lists — details/rows endpoints never attach one. |
| ETA does not move after editing the setup | Correct. Orders freeze their configuration into `orders.eta_snapshot` at placement. Only orders placed **after** the edit follow it. |
| `text` says hours but `min`/`max` look huge | Correct. `min`/`max` are always minutes; `text` is the scaled label. |

---

## 9. Test data used to capture this file

Created on this install to make the examples runnable:

```bash
# EtaConfiguration id 2508 — zone 1, module 1, distance_based, 20 / 10 / 5 / gap 15
php artisan tinker --execute="\App\Models\EtaConfiguration::find(2508)?->delete();"
```

The vendor auth token for vendor 1 was also regenerated to run the vendor curls, which
invalidates any vendor-app session that was already signed in as that account. Signing in again
issues a fresh one.
