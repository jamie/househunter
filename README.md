# README

## Importing listings

`rails mls:import` pulls listings from realtor.ca. The HTTP fetch lives in
`lib/realtor_fetch.py` rather than in Ruby: realtor.ca is behind Cloudflare bot
management that fingerprints the TLS/HTTP2 handshake, and every OpenSSL-based
client (Ruby's http gem, plain curl) gets a 403 block page no matter what
cookies it sends. `curl_cffi` replays a real Firefox handshake, which clears it.

Local setup needs Python 3 plus one package:

    pip install curl_cffi

The Dockerfile installs both in the runtime stage. No API key or hand-copied
cookie is involved -- the script mints the short-lived `cf_api_tok` it needs by
loading a realtor.ca page first.

---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
