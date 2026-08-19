#!/usr/bin/env python3
"""Fetch realtor.ca listings and emit them as NDJSON on stdout.

Invoked by Importer (app/models/importer.rb), which owns everything after
this: parsing, diffing, persistence. This script exists purely because
realtor.ca sits behind Cloudflare bot management that fingerprints the
TLS/HTTP2 handshake (JA3/JA4). Ruby's http gem -- or any OpenSSL client,
including plain curl -- gets a hard 403 block page on every request, even
for the unauthenticated homepage, and no cookie value can talk it out of
that. curl_cffi replays a real Firefox handshake, which clears it.

There are two gates in front of the search API:

  1. The TLS fingerprint above, which applies to www and api2 alike.
  2. A cf_api_tok cookie, required by api2 only. It is NOT single-use and
     does not rotate, but it expires within ~15 minutes of being minted.

Loading any www.realtor.ca page mints a fresh cf_api_tok via Set-Cookie, so
gate 2 costs one extra request and needs no human in the loop. That is the
whole bootstrap: hit /map, then post searches on the same session.

Usage:  realtor_fetch.py '<json search params>'
Writes: one listing object per line on stdout
Exits:  0 ok, 2 blocked/non-JSON response, 3 bad usage, 4 missing dependency
"""

import json
import sys
import time

try:
    from curl_cffi import requests
except ImportError:
    sys.stderr.write(
        "curl_cffi is not installed. Install it with: pip install curl_cffi\n"
    )
    sys.exit(4)

BOOTSTRAP_URL = "https://www.realtor.ca/map"
SEARCH_URL = "https://api2.realtor.ca/Listing.svc/PropertySearch_Post"

# Firefox is what the site is most commonly browsed with, and what the
# captured request we reverse engineered came from.
IMPERSONATE = "firefox135"

# 200 is the ceiling -- RecordsPerPage=500 comes back with zero results. Worth
# staying at the ceiling: at 50 the server's paging is unstable and pages
# overlap, so you re-fetch rows you already have and the run drifts past
# TotalRecords instead of terminating cleanly.
RECORDS_PER_PAGE = 200

# Nothing legitimate needs this many pages at 200/page; it is a stop against
# looping forever if the API stops honouring the empty-page terminator.
MAX_PAGES = 60

# Small courtesy gap between pages. A full run is only a handful of requests.
PAGE_DELAY_SECONDS = 0.3

BROWSER_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
}

API_HEADERS = {
    "Accept": "*/*",
    "Referer": "https://www.realtor.ca/",
    "Origin": "https://www.realtor.ca",
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
}


def blocked(response, context):
    """Report a Cloudflare block and bail.

    The block page is served as text/html with no Access-Control-Allow-Origin
    header, which is why this same failure shows up in a browser's network
    panel as a misleading "CORS Missing Allow Origin" rather than as the 403
    it actually is.
    """
    sys.stderr.write(
        f"realtor.ca blocked the {context} request: HTTP {response.status_code} "
        f"{response.headers.get('content-type', 'unknown content type')}\n"
    )
    sys.exit(2)


def is_json(response):
    return "json" in (response.headers.get("content-type") or "")


def bootstrap(session):
    """Load a www page so the session picks up a fresh cf_api_tok."""
    response = session.get(BOOTSTRAP_URL, headers=BROWSER_HEADERS, timeout=30)
    if response.status_code != 200:
        blocked(response, "bootstrap")

    if not any(cookie.name == "cf_api_tok" for cookie in session.cookies.jar):
        sys.stderr.write(
            "Bootstrap succeeded but no cf_api_tok cookie was set. realtor.ca may "
            "have changed how the token is issued; the search request will fail.\n"
        )


def search_pages(session, params):
    """Yield each page's Results array until the API returns an empty page."""
    for page in range(1, MAX_PAGES + 1):
        body = dict(params)
        body["RecordsPerPage"] = RECORDS_PER_PAGE
        body["CurrentPage"] = page

        response = session.post(
            SEARCH_URL, data=body, headers=API_HEADERS, timeout=30
        )
        if not is_json(response):
            blocked(response, f"search (page {page})")

        results = response.json().get("Results", [])
        if not results:
            return
        yield results

        time.sleep(PAGE_DELAY_SECONDS)

    sys.stderr.write(
        f"Stopped after {MAX_PAGES} pages without an empty page. Results may be "
        f"incomplete -- check whether the search bounds are too broad.\n"
    )


def main():
    if len(sys.argv) != 2:
        sys.stderr.write("usage: realtor_fetch.py '<json search params>'\n")
        sys.exit(3)

    try:
        params = json.loads(sys.argv[1])
    except json.JSONDecodeError as error:
        sys.stderr.write(f"search params were not valid JSON: {error}\n")
        sys.exit(3)

    session = requests.Session(impersonate=IMPERSONATE)
    bootstrap(session)

    count = 0
    for results in search_pages(session, params):
        for listing in results:
            sys.stdout.write(json.dumps(listing) + "\n")
            count += 1
        sys.stdout.flush()

    sys.stderr.write(f"fetched {count} listings\n")


if __name__ == "__main__":
    main()
