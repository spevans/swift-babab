# Changelog

## 0.0.2

### `BitField`
- `BitArray` is now named `BitField` as it was never a real array, it was fixed witdth and composed of
  a fixed number of elements.
    
- `BitField` - The `Element` accessed by the `subscript` [] is now a `Bool` instead of an `Int`.

- The initialisers `init(_ rawValue: Int)` and `init(_ rawValue: UInt)` have been removed.

### `BinaryInteger`
- Removed `hexNum()` method and add the following methods on `BinaryInteger`:
  `.binary(separator: Bool = false)`
  `.octal(separator: Bool = false)`
  `.hex(separator: Bool = false)`

### `NumberSet`
- Added `NumberSet` to hold a `Set` of `UnsignedInteger` from value `0..<bitWidth` using a specified `FixedWidthInteger`
  as storage.

### `ByteArray`
- Added `ByteArray` to hold an `Array` of `UInt8` using a specified `FixedWidthInteger` as storage. This avoids
  allocating on the heap.

### Extensions

### `FixedWidthInteger`
- Added bit manipulation methods to `FixedWidthInteger`:
    - `bit(_:)`
    - `bit(_:_)`
    - `.lowestBitSet`
    - `.highestBitSet`
    - `clearLowestBitSet()`
    - `clearHighestBitSet()`

- Added initialisers to `FixedWidthInteger` types that read from a little or bit endian `Collection`.

- Added BCD methods to `FixedWidthInteger`:
  - `init?(bcd: Self)`
  - `.bcdValue`
