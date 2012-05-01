# AFCollectionJSONRequestOperation

`AFCollectionJSONRequestOperation` is an `AFJSONRequestOperation` subclass for working with the [Collection+JSON Hypermedia Type](http://www.amundsen.com/media-types/collection/).

Specifically, `AFCollectionJSONRequestOperation` provides a `AFCollectionJSONCollection` response object, which contains an array of `AFCollectionJSONItem` objects. `{"name": ..., "value": ...}` becomes an `NSDictionary` with keys and values, URL strings become `NSURL`, and links are keyed by `rel` in the `linksKeyedByRel` property.

**Caution:** This code is still in its early stages of development, so exercise caution when incorporating this into production code.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AFCollectionJSONRequestOperation is available under the MIT license. See the LICENSE file for more info.
