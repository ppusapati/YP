# samavaya-client

Python client for the YieldPoint agriculture platform.

```bash
pip install -e .
```

```python
from samavaya import ApiError, Client

with Client("http://localhost:8080") as api:
    api.login("agronomist@example.com", "…")

    for farm in api.paginate(
        "agriculture.farm.v1.FarmService", "ListFarms",
        {"page_size": 50}, "farms",
    ):
        print(farm["name"])
```

## Why there is no code generation here

ConnectRPC over JSON is an ordinary HTTP API: every call is
`POST /<proto package>.<Service>/<Method>` with a JSON body. Generated Python
message classes would add a build step, a CI freshness gate and a few thousand
checked-in files, and would buy nothing that a dict does not already give a
Python caller. Go and TypeScript generate because their compilers can check the
result; Python's cannot, so the cost is all cost.

What is worth having in a client, and is here, is the part that is easy to get
wrong:

- **Auth**: login, and refresh a minute ahead of expiry — a token that expires
  mid-flight fails after the server has done the work. A `401` triggers exactly
  one refresh-and-retry.
- **Retries**: only on `unavailable`, `deadline_exceeded`, `resource_exhausted`
  and `aborted`. Repeating an `invalid_argument` produces the same answer more
  slowly.
- **Pagination**: handles both the offset and token styles the platform uses,
  and terminates even against a server that hands back the token it was given.
- **Errors**: `ApiError.reason` carries the platform's machine-readable reason
  (`FARM_NOT_FOUND`), which is what you should branch on. `.code` says what kind
  of failure it was; `.message` is written for people and changes without
  notice.

## Tests

```bash
python -m unittest discover -s tests
```

They run against a real `http.server`, not a mocked transport, because what is
worth testing here is what goes over the wire.
