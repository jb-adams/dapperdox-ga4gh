# Design principles

This API provides a means of retrieving data from several types of RNA experiments including:

* Feature-level expression data from RNA-seq type measurements
* Coordinate-based signal/intensity data similar to a bigwig representation

via a client/server model.

Features of this API include:

* Support for a hierarchical data model which provides the option for servers to associate expression data for discovery and retrieval
* Support for accessing subsets of expression data through slicing operations on the expression matrix and/or query filters to specify features to be included
* Support for accessing signal/intensity data by specifying a range of genomic coordinates to be included

Out of the scope of this API are:

* A means of retrieving primary (raw) read sequence data. Input samples are identified in expression output and data servers should implement additional API(s) to allow for search and retrieval of raw reads. The [htsget API](https://samtools.github.io/hts-specs/htsget.html) is designed for retrieval of read data.
* A means of retrieving reference sequences. Servers should implement additional API(s) to allow for search and retrieval of reference base sequences. The [refget API](https://samtools.github.io/hts-specs/refget.html) is designed for retrieval of references sequences.
* A means of retrieving feature annotation details. Expression matrices provide the identity of each mapped feature. Servers should implement additional API(s) to allow for search and retrieval of genomic feature annotation details.

## OpenAPI Description

An OpenAPI description of this specification is available and [describes the 1.0.0 version](rnaget-openapi.yaml). OpenAPI is an independent API description format for describing REST services and is compatible with a number of [third party tools](http://openapi.tools/).

## Compliance

Implementors can check if their RNAget implementations conform to the
specification by using our [compliance suite](https://github.com/ga4gh-rnaseq/rnaget-compliance-suite).

## Protocol essentials

All API invocations are made to a configurable HTTPS endpoint, receive URL-encoded query string parameters and HTTP headers, and return text or other allowed formatting as requested by the user. Queries containing [unsafe or reserved](https://www.ietf.org/rfc/rfc1738.txt) characters in the URL, including but not limited to "&", "/", "#", MUST encode all such characters.  Successful requests result with HTTP status code 200 and have the appropriate text encoding in the response body as defined for each endpoint. The server may provide responses with chunked transfer encoding. The client and server may mutually negotiate HTTP/2 upgrade using the standard mechanism.

HTTP responses may be compressed using [RFC 2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html) transfer-coding, not content-coding.

HTTP response may include a 3XX response code and Location header redirecting the client to retrieve expression data from an alternate location as specified by [RFC 7231](https://tools.ietf.org/html/rfc7231), clients SHOULD be configured to follow redirects. `302`, `303` and `307` are all valid response codes to use.

Responses from the server MUST include a Content-Type header containing the encoding for the invoked method and protocol version.  Unless negotiated with the client and allowed by the server, the default encoding is:

```
Content-Type: application/vnd.ga4gh.rnaget.v1.0.0+json; charset=us-ascii
```

All response objects from the server are expected to be in JSON format, regardless of the response status code, unless otherwise negotiated with the client and allowed by the server.

Object IDs are intended for persistent retrieval of their respective objects.  An object ID MUST uniquely identify an object within the scope of a single data server.  It is beyond the scope of this API to enforce uniqueness of ID among different data servers.  IDs are strings made up of uppercase and lowercase letters, decimal digits, hypen, period, underscore and tilde [A-Za-z0-9.-_~]. See [RFC 3986 § 2.3](https://tools.ietf.org/html/rfc3986#section-2.3).

Endpoints are described as HTTPS GET methods which will be sufficient for most queries.  Queries containing multiple metadata filters may approach or exceed the URL length limits.  To handle these types of queries it is recommended that servers SHOULD implement parallel HTTPS POST endpoints accepting the same URL parameters as a UTF8-encoded JSON key-value dictionary.

When processing requests containing multiple filters and filters with lists of items, the data provider MUST use a logical `AND` for selecting the results to return.

## Internet Media Types Handling

When responding to a request a server MUST use the fully specified media type for that endpoint. When determining if a request is well-formed, a server MUST allow a internet type to degrade like so

  - `application/vnd.ga4gh.rnaget.v1.0.0+json; charset=us-ascii`
  - `application/vnd.ga4gh.rnaget.v1.0.0+json`
  - `application/json`    

## Errors

The server MUST respond with an appropriate HTTP status code (4xx or 5xx) when an error condition is detected. In the case of transient server errors (e.g., 503 and other 5xx status codes), the client SHOULD implement appropriate retry logic. For example, if a client sends an alphanumeric string for a parameter that is specified as unsigned integer the server MUST reply with `Bad Request`.

| Error type        | HTTP status code | Description
|-------------------|------------------|-------------|
| `Bad Request`     | 400 | Cannot process due to malformed request, the requested parameters do not adhere to the specification |
| `Unauthorized`    | 401 | Authorization provided is invalid |
| `Not Found`       | 404 | The resource requested was not found |
| `Not Acceptable`  | 406 | The requested formatting is not supported by the server |
| `Not Implemented` | 501 | The specified request is not supported by the server |

## Security

The RNAget API can be used to retrieve potentially sensitive genomic data and is dependent on the implementation.  Effective security measures are essential to protect the integrity and confidentiality of these data.

Sensitive information transmitted on public networks, such as access tokens and human genomic data, MUST be protected using Transport Level Security (TLS) version 1.2 or later, as specified in [RFC 5246](https://tools.ietf.org/html/rfc5246).

If the data holder requires client authentication and/or authorization, then the client's HTTPS API request MUST present an OAuth 2.0 bearer access token as specified in [RFC 6750](https://tools.ietf.org/html/rfc6750), in the Authorization request header field with the Bearer authentication scheme:

```
Authorization: Bearer [access_token]
```

Data providers SHOULD verify user identity and credentials.  The policies and processes used to perform user authentication and authorization, and the means through which access tokens are issued, are beyond the scope of this API specification. GA4GH recommends the use of the OAuth 2.0 framework ([RFC 6749](https://tools.ietf.org/html/rfc6749)) for authentication and authorization.  It is also recommended that implementations of this standard also implement and follow the GA4GH [Authentication and Authorization Infrastructure (AAI) standard](https://docs.google.com/document/d/1zzsuNtbNY7agPRjfTe6gbWJ3BU6eX19JjWRKvkFg1ow).

## CORS
Cross-origin resource sharing (CORS) is an essential technique used to overcome the same origin content policy seen in browsers. This policy restricts a webpage from making a request to another website and leaking potentially sensitive information. However the same origin policy is a barrier to using open APIs. GA4GH open API implementers should enable CORS to an acceptable level as defined by their internal policy. For any public API implementations should allow requests from any server.

GA4GH is publishing a [CORS best practices document](https://docs.google.com/document/d/1Ifiik9afTO-CEpWGKEZ5TlixQ6tiKcvug4XLd9GNcqo/edit?usp=sharing), which implementers should refer to for guidance when enabling CORS on public API instances.

## Possible Future API Enhancements

- Allow OR for search filters
- Report size of download file
- Matrix slicing with bool array or list of indices

## API specification change log

1.0.0    Initial release version
