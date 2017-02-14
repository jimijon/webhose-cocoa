// swiftlint:disable line_length
/***********************************************************************************
 *
 * Copyright (c) 2012 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

 /**
 * Swift Helpers
 */

import OHHTTPStubs

// MARK: Syntaxic Sugar for OHHTTPStubs

/**
* Helper to return a `OHHTTPStubsResponse` given a fixture path, status code and optional headers.
*
* - Parameter filePath: the path of the file fixture to use for the response
* - Parameter status: the status code to use for the response
* - Parameter headers: the HTTP headers to use for the response
*
* - Returns: The `OHHTTPStubsResponse` instance that will stub with the given status code
*            & headers, and use the file content as the response body.
*/
public func fixture(_ filePath: String, status: Int32 = 200, headers: [AnyHashable: Any]?) -> OHHTTPStubsResponse {
    return OHHTTPStubsResponse(fileAtPath: filePath, statusCode: status, headers: headers)
}

/**
 * Helper to call the stubbing function in a more concise way?
 *
 * - Parameter condition: the matcher block that determine if the request will be stubbed
 * - Parameter response: the stub reponse to use if the request is stubbed
 *
 * - Returns: The opaque `OHHTTPStubsDescriptor` that uniquely identifies the stub
 *            and can be later used to remove it with `removeStub:`
 */
public func stub(_ condition: @escaping OHHTTPStubsTestBlock, response: @escaping OHHTTPStubsResponseBlock) -> OHHTTPStubsDescriptor {
    return OHHTTPStubs.stubRequests(passingTest: condition, withStubResponse: response)
}

// MARK: Create OHHTTPStubsTestBlock matchers

/**
* Matcher for testing an `NSURLRequest`'s **scheme**.
*
* - Parameter scheme: The scheme to match
*
* - Returns: a matcher (OHHTTPStubsTestBlock) that succeeds only if the request
*            has the given scheme
*/
public func isScheme(_ scheme: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.scheme == scheme }
}

/**
 * Matcher for testing an `NSURLRequest`'s **host**.
 *
 * - Parameter host: The host to match
 *
 * - Returns: a matcher (OHHTTPStubsTestBlock) that succeeds only if the request
 *            has the given host
 */
public func isHost(_ host: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.host == host }
}

/**
 * Matcher for testing an `NSURLRequest`'s **path**.
 *
 * - Parameter path: The path to match
 *
 * - Returns: a matcher (OHHTTPStubsTestBlock) that succeeds only if the request
 *            has exactly the given path
 *
 * - Note: URL paths are usually absolute and thus starts with a '/' (which you
 *         should include in the `path` parameter unless you're testing relative URLs)
 */
public func isPath(_ path: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.path == path }
}

/**
 * Matcher for testing an `NSURLRequest`'s **path extension**.
 *
 * - Parameter ext: The file extension to match (without the dot)
 *
 * - Returns: a matcher (OHHTTPStubsTestBlock) that succeeds only if the request path
 *            ends with the given extension
 */
public func isExtension(_ ext: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.pathExtension == ext }
}

/**
 * Matcher for testing an `NSURLRequest`'s **query parameters**.
 *
 * - Parameter params: The dictionary of query parameters to check the presence for
 *
 * - Returns: a matcher (OHHTTPStubsTestBlock) that succeeds if the request contains
 *            the given query parameters with the given value.
 *
 * - Note: There is a difference between:
 *          (1) using `[q:""]`, which matches a query parameter "?q=" with an empty value, and
 *          (2) using `[q:nil]`, which matches a query parameter "?q" without a value at all
 */
@available(iOS 8.0, OSX 10.10, *)
public func containsQueryParams(_ params: [String:String?]) -> OHHTTPStubsTestBlock {
    return { req in
        if let url = req.url {
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let queryItems = comps?.queryItems {
                for (k, v) in params {
                    if queryItems.filter({ qi in qi.name == k && qi.value == v }).count == 0 { return false }
                }
                return true
            }
        }
        return false
    }
}

// MARK: Operators on OHHTTPStubsTestBlock

/**
* Combine different `OHHTTPStubsTestBlock` matchers with an 'OR' operation.
*
* - Parameter lhs: the first matcher to test
* - Parameter rhs: the second matcher to test
*
* - Returns: a matcher (`OHHTTPStubsTestBlock`) that succeeds if either of the given matchers succeeds
*/
public func || (lhs: @escaping OHHTTPStubsTestBlock, rhs: @escaping OHHTTPStubsTestBlock) -> OHHTTPStubsTestBlock {
    return { req in lhs(req) || rhs(req) }
}

/**
 * Combine different `OHHTTPStubsTestBlock` matchers with an 'AND' operation.
 *
 * - Parameter lhs: the first matcher to test
 * - Parameter rhs: the second matcher to test
 *
 * - Returns: a matcher (`OHHTTPStubsTestBlock`) that only succeeds if both of the given matchers succeeds
 */
public func && (lhs: @escaping OHHTTPStubsTestBlock, rhs: @escaping OHHTTPStubsTestBlock) -> OHHTTPStubsTestBlock {
    return { req in lhs(req) && rhs(req) }
}

/**
 * Create the opposite of a given `OHHTTPStubsTestBlock` matcher.
 *
 * - Parameter expr: the matcher to negate
 *
 * - Returns: a matcher (OHHTTPStubsTestBlock) that only succeeds if the expr matcher fails
 */
public prefix func ! (expr: @escaping OHHTTPStubsTestBlock) -> OHHTTPStubsTestBlock {
    return { req in !expr(req) }
}
// swiftlint:enable line_length
