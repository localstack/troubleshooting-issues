# issue

[https://github.com/localstack/localstack/issues/5406](https://github.com/localstack/localstack/issues/5406)

## deploy

```bash
./run.sh
```

## test

```bash
curl -X POST "http://localhost:4566/restapis/<rest-api-id>/local/_user_request_/sites/1/ingest"  -H 'Content-Type: application/json' -d '{
      "HID": "ad",
      "SID": "consequat ex velit sed",
      "Data": {
        "ipsum_e_": 50662226
      }
    }'
```