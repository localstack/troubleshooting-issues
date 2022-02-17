# issue

[https://github.com/localstack/localstack/issues/5498](https://github.com/localstack/localstack/issues/5498)

## installation

```bash
npm install
```

## deploy

```bash
cdklocal bootstrap
cdklocal deploy
```

## test

```bash
curl --location --request POST 'http://localhost:4566/restapis/<rest-api-id>/dev/_user_request_/event' \
--header 'Content-Type: application/json' \
--data-raw '{
    "test": "data"
}
'
```